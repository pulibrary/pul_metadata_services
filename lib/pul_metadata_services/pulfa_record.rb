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
        title: title
        # more TODO
      }
    end

    def title
      [ data.at_xpath('/c/did/unittitle').text ]
    end

    def component_creators
      # TODO
    end

    def component_date
      # TODO
    end

    def breadcrumbs
      crumbs = data.xpath('/c/context/breadcrumbs/crumb')
      crumbs.map(&:text).join(' 》')
    end

    def collection_title
      data.at_xpath('/c/context/collectionInfo/unittitle').content
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

  end
end
