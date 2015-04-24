require 'spec_helper'
require 'pul_metadata_services'

vcr_options = {
  record: :new_episodes,
  serialize_with: :json
}

describe PulMetadataServices, vcr: vcr_options do
  # To the extent that this is useful and the source records don't change...
  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:marcxml) { File.open(File.join(fixture_path, '4609321.mrx')).read.strip }
  let(:ead) { File.open(File.join(fixture_path, 'AC044_c0003.xml')).read.strip }
  subject {
    klass = Class.new do
      include PulMetadataServices
    end
    klass.new
  }

  describe '#retrieve_from_pulfa' do
    it 'does' do
      expect(subject.retrieve_from_pulfa('AC044_c0003')).to eq ead
    end
  end

  describe '#retrieve_from_bibdata' do
    it 'does' do
      expect(subject.retrieve_from_bibdata('4609321')).to eq marcxml
    end
  end
end
