require 'nokogiri'

module PulMetadataServices
  class PulfaRecord
    attr_reader :full_source
    def initialize(source, full_source=nil)
      @source = source
      @full_source = full_source
    end

    def source
      @source
    end

    def attributes
      if collection?
        CollectionAttributes
      else
        Attributes
      end.new(data).attributes
    end

    def collection?
      !data.at_xpath('/archdesc').nil?
    end

    private

      def data
        @data ||= reader.remove_namespaces!
      end

      def reader
        @reader ||= Nokogiri::XML(source)
      end

      class Attributes
        attr_reader :data

        # Constructor
        # @param data [Nokogiri::XML::Node]
        def initialize(data)
          @data = data
        end

        # Generate the Hash of metadata attributes for the resource
        # @return [Hash]
        def attributes
          {
            title: title,
            language: language,
            date_created: display_date,
            created: normalized_date,
            extent: extent,
            container: container,
            heldBy: location_code,
            creator: collection_creators,
            publisher: collection_creators,
            memberOf: collections
          }
        end

        # Retrieve the title for the resource
        # @return [Array<String>]
        def title
          [ unittitle_element.text.gsub(/\s+/, ' ') ]
        end

        # Retrieve the IETF language tag for the resource
        # @return [String]
        def language
          text(data.at_xpath("#{data_root}/did/langmaterial/language/@langcode"))
        end

        # Retrieve the human-readable date string for the resource
        # @return [String]
        def display_date
          text(data.at_xpath("#{data_root}/did/unitdate"))
        end

        # Retrieve the normalized date for the resource
        # @return [String]
        def normalized_date
          text(data.at_xpath("#{data_root}/did/unitdate/@normal"))
        end

        # Retrieve the physical extent for the resource
        # @return [String]
        def extent
          text(data.at_xpath("#{data_root}/did/physdesc/extent"))
        end

        # Retrieve the physical containers encoded for the resource
        # e. g. items encoded as having been stored in a box or folder
        # @return [Array<String>]
        def container
          [ [container_parent, container_element('box'), container_element('folder')].compact.join(', ') ]
        end

        # Retrieve the location code for the resource
        # @return [String]
        def location_code
          text(data.at_xpath("#{data_root}/did/physloc"))
        end

        # Retrieve the creator information encoded for the collection in which the item is stored
        # @return [Array<String>]
        def collection_creators
          cres = data.xpath("#{data_root}/context/collectionInfo/collection-creators/*")
          cres.map(&:content).map(&:strip)
        end

        # Retrieve the title and identifier information encoded for the collection in which the item is stored
        # @return [Array<Hash>]
        def collections
          [{
            title: data.at_xpath("#{data_root}/context/collectionInfo/unittitle").content,
            identifier: data.at_xpath("#{data_root}/context/collectionInfo/unitid").content
          }]
        end

        def component_creators
          # TODO
        end

        def collection_date
          # TODO
        end

        private

          # look for a component title; if not found look for a collection title
          # @return [Nokogiri::XML::Node]
          def unittitle_element
            data.at_xpath("#{data_root}/did/unittitle")
          end

          # Retrieve additional information about the title encoded for the resource
          # @return [String]
          def breadcrumbs
            crumbs = data.xpath("#{data_root}/context/breadcrumbs/crumb")
            crumbs.map(&:text).compact.join(' - ')
          end

          # Generate the XPath used in the Document for retrieving structural metadata
          # @return [String]
          def data_root
            '/c'
          end

          # Retrieve the text from an XML Element
          # @param result [Nokogiri::XML::Node]
          # @return [Array<String>]
          def text(result)
            [ result.text ] if result
          end

          # Generate a description of the parent container for the item (using an encoded ID)
          # @return [String]
          def container_parent
            parent_id = data.at_xpath("/c/did/container/@parent")
            return unless parent_id
            parent = data.at_xpath("//c[@id='#{parent_id}']/did/container")
            "#{parent.attribute('type').value.capitalize} #{parent.content}"
          end

          # Generate a description of the parent container for the item (using an encoded container type)
          # @param type [String]
          # @return [String]
          def container_element(type)
            val = text(data.at_xpath("/c/did/container[@type='#{type}']"))
            "#{type.capitalize} #{val.first}" if val
          end
      end

      class CollectionAttributes < Attributes
        def attributes
          {
            title: title,
            language: language,
            date_created: display_date,
            created: normalized_date,
            extent: extent,
            heldBy: location_code,
          }
        end

        def data_root
           '/archdesc'
        end

        def collections
          []
        end
      end
  end
end
