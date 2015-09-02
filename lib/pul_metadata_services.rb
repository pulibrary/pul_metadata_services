require 'marc'
require 'faraday'
require File.expand_path('../ext/marc', __FILE__)

module PulMetadataServices
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Version
    autoload :PulfaRecord
  end

  def retrieve_from_pulfa(id)
    response = pulfa_connection.get(id.gsub('_','/')+".xml?scope=record" )
    response.body
  end

  def retrieve_from_bibdata(id)
    response = bibdata_connection.get(id)
    response.body
  end

  private

  def pulfa_connection
    @pulfa_connection ||= Faraday.new(url: 'http://findingaids.princeton.edu/collections/')
  end

  def bibdata_connection
    @bibdata_connection ||= Faraday.new(url: 'http://bibdata.princeton.edu/bibliographic/')
  end

end
