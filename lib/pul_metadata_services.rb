require 'marc'
require 'faraday'
require 'active_support'

module PulMetadataServices
  extend ::ActiveSupport::Autoload

  eager_autoload do
    autoload :Version
    autoload :PulfaRecord
    autoload :BibRecord
    autoload :Client
  end

end
