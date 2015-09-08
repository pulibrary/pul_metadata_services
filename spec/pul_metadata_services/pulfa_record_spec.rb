require 'spec_helper'
require 'pul_metadata_services'

describe PulMetadataServices::PulfaRecord do
  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:record1_path) { File.join(fixture_path, 'AC123_c00004.xml')}
  subject {
    f = File.open(record1_path)
    su = PulMetadataServices::PulfaRecord.new(f.read)
    f.close
    su
  }

  describe '#attributes' do
    it 'works' do
      expected = {
        title: ['19th Century Catalog and Correspondence, Pre-Vinton, 1811-']
      }
      expect(subject.attributes).to eq expected
    end
  end

  describe '#title' do
    it 'Grabs the unittitle' do
      expected = ['19th Century Catalog and Correspondence, Pre-Vinton, 1811-']
      expect(subject.title).to eq expected
    end
  end

  describe '#breadcrumbs' do
    it 'returns the path without the title' do
      expected = 'Series 1: University Librarian Records 》Subseries 1A, Frederic Vinton 》Correspondence'
      expect(subject.breadcrumbs).to eq expected
    end
  end

  describe '#collection_title' do
    it 'returns the path without the title' do
      expected = 'Princeton University Library Records'
      expect(subject.collection_title).to eq expected
    end
  end

  describe '#collection_creators' do
    it 'returns the path without the title' do
      expected = ["Princeton University. Library. Dept. of Rare Books and Special Collections"]
      expect(subject.collection_creators).to eq expected
    end
  end

end
