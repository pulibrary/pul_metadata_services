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
  let(:ead_full) { File.open(File.join(fixture_path, 'AC044_c0003_full.xml')).read.strip }
  let(:ead2) { File.open(File.join(fixture_path, 'RBD1_c13076.xml')).read.strip }
  before do
    VCR.turn_on!
  end

  context 'with a Voyager-like id' do
    it 'makes requests to Voyager' do
      expect(described_class.retrieve('4609321').source).to eq marcxml
      expect(described_class.retrieve('4609321').full_source).to eq marcxml
    end
  end
  context 'with a Pulfa-like id' do
    it 'makes requests to PULFA' do
      output = described_class.retrieve('AC044_c0003')
      expect(output.source).to eq ead
      expect(output.full_source).to eq ead_full
    end
  end
  context 'with a Pulfa-like id, when the metadata contains non-ASCII characters' do
    it 'makes requests to PULFA and parses character encoding correctly' do
      expect(described_class.retrieve('RBD1_c13076').source).to eq ead2
    end
  end
end
