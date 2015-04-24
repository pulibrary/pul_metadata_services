require 'nokogiri'

module PulMetadataServices
  class PulfaRecord

    attr_accessor :record

    def initialize(record)
      # Just asssuming record is a String for now
      # unless record.instance_of? Nokogiri::XML::Document
      self.record = Nokogiri::XML(record)
      #else
      #  self.record = record
      #end
      self.record.remove_namespaces!
    end


    # # probably will need a sorting routine for
    # # that provides precedence to the attributes
    def component_title
      self.record.at_xpath('/c/did/unittitle').text
    end

    def component_creators
      # TODO
    end

    def component_date
      # TODO
    end

    def breadcrumbs
      crumbs = self.record.xpath('/c/context/breadcrumbs/crumb')
      crumbs.map(&:text).join(' 》')
    end

    def collection_title
      self.record.at_xpath('/c/context/collectionInfo/unittitle').content
    end

    def collection_creators
      cres = self.record.xpath('/c/context/collectionInfo/collection-creators/*')
      cres.map(&:content)
    end

    def collection_date
      # TODO
    end

  end
end
