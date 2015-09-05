require 'spec_helper'
require 'pul_metadata_services'

vcr_options = {
  record: :new_episodes,
  serialize_with: :json
}

describe PulMetadataServices::Client, vcr: vcr_options do

  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:marcxml) { File.open(File.join(fixture_path, '4609321.mrx')).read.strip }
  let(:ead) { File.open(File.join(fixture_path, 'AC044_c0003.xml')).read.strip }

  context 'with a Voyager-like id' do
    it 'makes requests to Voyager' do
      expect(described_class.retrieve('4609321').source).to eq marcxml
    end
  end
  context 'with a Pulfa-like id' do
    it 'makes requests to PULFA' do
      expect(described_class.retrieve('AC044_c0003').source).to eq ead
    end
  end
end
