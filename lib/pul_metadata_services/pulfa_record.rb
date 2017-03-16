require 'nokogiri'

module PulMetadataServices
  class PulfaRecord

    def initialize(source)
      @source = source
    end

    def source
      @source
    end

    def attributes
      {
        title: title,
        language: language,
        date: display_date,
        created: normalized_date,
        extent: extent,
        description: description,
        heldBy: location_code,
        creator: collection_creators,
        publisher: collection_creators
      }
    end

    def title
      [ [ breadcrumbs, data.at_xpath('/c/did/unittitle').text ].compact.join(' - ') ]
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

    def description
      [ [container('box'), container('folder')].compact.join(', ') ]
    end

    def extent
      text(data.at_xpath('/c/did/physdesc/extent'))
    end

    def component_creators
      # TODO
    end

    def breadcrumbs
      crumbs = data.xpath('/c/context/breadcrumbs/crumb')
      crumbs.map(&:text).join(' - ')
    end

    def collection_title
      [ data.at_xpath('/c/context/collectionInfo/unittitle').content ]
    end

    def collection_creators
      cres = data.xpath('/c/context/collectionInfo/collection-creators/*')
      cres.map(&:content)
    end

    def collection_date
      # TODO
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

    def container(type)
      val = text(data.at_xpath("/c/did/container[@type='#{type}']")).first
      "#{type.capitalize} #{val}" if val
    end
  end
end
