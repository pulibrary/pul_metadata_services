require 'marc'
require File.expand_path('../ext/marc', __FILE__)
require 'net/http'
require 'uri'
require 'rdf'

module PulMetadataServices
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Version
    autoload :ExternalMetadataSource
  end

end
