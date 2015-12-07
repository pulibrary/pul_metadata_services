module PulMetadataServices

  class Client

    def self.retrieve(id)
      if bibdata?(id)
        src = retrieve_from_bibdata(id)
        record = PulMetadataServices::BibRecord.new(src)
      else
        src = retrieve_from_pulfa(id)
        record = PulMetadataServices::PulfaRecord.new(src)
      end
      record
    end

    private

    def self.bibdata?(source_metadata_id)
      source_metadata_id =~ /\A\d+\z/
    end

    def self.retrieve_from_pulfa(id)
      conn = Faraday.new(url: 'http://findingaids.princeton.edu/collections/')
      response = conn.get("#{id.gsub('_','/')}.xml", scope: "record" )
      response.body
    end

    def self.retrieve_from_bibdata(id)
      conn = Faraday.new(url: 'https://bibdata.princeton.edu/bibliographic/')
      response = conn.get(id)
      response.body
    end

  end
end
