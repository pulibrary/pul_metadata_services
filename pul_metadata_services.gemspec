# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pul_metadata_services/version'

Gem::Specification.new do |spec|
  spec.name          = "pul_metadata_services"
  spec.version       = PulMetadataServices::VERSION
  spec.authors       = ["Jon Stroop"]
  spec.email         = ["jpstroop@gmail.com"]
  spec.summary       = %q{A library for connecting with PUL metadata webservices and parsing MARC or EAD metadata }
  spec.description   = ""
  spec.homepage      = %q{https://github.com/pulibrary/pul_metadata_services}
  spec.license       = "APACHE2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'marc', '~> 1.0.0'
  spec.add_dependency 'activesupport', '~> 4.2.1'
  spec.add_dependency 'faraday', '~> 0.9.1'
  spec.add_dependency 'nokogiri', '~> 1.6.6.2'

  spec.add_development_dependency 'vcr', '~> 2.9.3'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency 'webmock', '~> 1.21.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.0'
end
