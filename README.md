# PUL Metadata Services

[![Circle CI](https://circleci.com/gh/pulibrary/pul_metadata_services.svg?style=svg)](https://circleci.com/gh/pulibrary/pul_metadata_services)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)


A client and set of convenience methods for retrieving metadata from PUL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pul_metadata_services'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pul_metadata_services

## Usage

```ruby
2.2.1 :001 > require 'pul_metadata_services'
 => true
2.2.1 :002 > record = PulMetadataServices::Client.retrieve('4609321')
 => #<PulMetadataServices::BibRecord:0x00000000eca950 @source="<record [...]
2.2.1 :003 > record.class
 => PulMetadataServices::BibRecord
2.2.1 :004 > record.source
 => "<record xmlns='http://www.loc.gov/MARC21/slim'><leader>01890cam a22 " [...]
2.2.1 :006 > record.title
 => ["Biblia Latina."]
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pul_metadata_services/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
