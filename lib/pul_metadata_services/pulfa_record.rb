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

    def title
      [ [ breadcrumbs, unittitle_element.text ].reject(&:empty?).join(' - ') ].map { |s| s.gsub(/\s+/, ' ') }
    end

    # look for a component title; if not found look for a collection title
    def unittitle_element
      if collection?
        data.at_xpath('/archdesc/did/unittitle')
      else
        data.at_xpath('/c/did/unittitle')
      end
    end

    def language
      text(data.at_xpath('/c/did/langmaterial/language/@langcode'))
    end

    def normalized_date
      text(data.at_xpath('/c/did/unitdate/@normal'))
    end

    def display_date
      text(data.at_xpath('/c/did/unitdate'))
    end

    def location_code
      text(data.at_xpath('/c/did/physloc'))
    end

    def container
      [ [container_parent, container_element('box'), container_element('folder')].compact.join(', ') ]
    end

    def extent
      text(data.at_xpath('/c/did/physdesc/extent'))
    end

    def component_creators
      # TODO
    end

    def breadcrumbs
      crumbs = data.xpath('/c/context/breadcrumbs/crumb')
      crumbs.map(&:text).compact.join(' - ')
    end

    def collections
      return [] if collection?
      [{
        title: data.at_xpath('/c/context/collectionInfo/unittitle').content,
        identifier: data.at_xpath('/c/context/collectionInfo/unitid').content
      }]
    end

    def collection_creators
      cres = data.xpath('/c/context/collectionInfo/collection-creators/*')
      cres.map(&:content).map(&:strip)
    end

    def collection_date
      # TODO
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

    def text(result)
      [ result.text ] if result
    end

    def container_parent
      parent_id = data.at_xpath("/c/did/container/@parent")
      return unless parent_id
      parent = data.at_xpath("//c[@id='#{parent_id}']/did/container")
      "#{parent.attribute('type').value.capitalize} #{parent.content}"
    end

    def container_element(type)
      val = text(data.at_xpath("/c/did/container[@type='#{type}']"))
      "#{type.capitalize} #{val.first}" if val
    end
  end
end
