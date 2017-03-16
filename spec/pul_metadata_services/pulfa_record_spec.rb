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
        title: ['Series 1: University Librarian Records - Subseries 1A, Frederic Vinton - Correspondence - 19th Century Catalog and Correspondence, Pre-Vinton, 1811-'],
        created: ['1865-01-01T00:00:00Z/1865-12-31T23:59:59Z'],
        creator: ['Princeton University. Library. Dept. of Rare Books and Special Collections'],
        publisher: ['Princeton University. Library. Dept. of Rare Books and Special Collections'],
        date: ['circa 1865'],
        description: ['Box 1, Folder 2'],
        extent: ['1 folder'],
        heldBy: ['mudd'],
        language: ['eng']
      }
      expect(subject.attributes).to eq expected
    end
  end

  describe '#title' do
    it 'Grabs the unittitle' do
      expected = ['Series 1: University Librarian Records - Subseries 1A, Frederic Vinton - Correspondence - 19th Century Catalog and Correspondence, Pre-Vinton, 1811-']
      expect(subject.title).to eq expected
    end
  end

  describe '#breadcrumbs' do
    it 'returns the path without the title' do
      expected = 'Series 1: University Librarian Records - Subseries 1A, Frederic Vinton - Correspondence'
      expect(subject.breadcrumbs).to eq expected
    end
  end

  describe '#collection_title' do
    it 'returns the path without the title' do
      expected = ['Princeton University Library Records']
      expect(subject.collection_title).to eq expected
    end
  end

  describe '#collection_creators' do
    it 'returns the path without the title' do
      expected = ["Princeton University. Library. Dept. of Rare Books and Special Collections"]
      expect(subject.collection_creators).to eq expected
    end
  end

  describe '#language' do
    it 'returns the language code' do
      expect(subject.language).to eq ['eng']
    end
  end

  describe '#normalized_date' do
    it 'returns the iso 8601 date' do
      expect(subject.normalized_date).to eq ['1865-01-01T00:00:00Z/1865-12-31T23:59:59Z']
    end
  end

  describe '#display_date' do
    it 'returns the human-readable date' do
      expect(subject.display_date).to eq ['circa 1865']
    end
  end

  describe '#extent' do
    it 'returns the extent' do
      expect(subject.extent).to eq ['1 folder']
    end
  end

  describe '#description' do
    it 'returns the box/folder' do
      expect(subject.description).to eq ['Box 1, Folder 2']
    end
  end

  describe '#location_code' do
    it 'returns the location code' do
      expect(subject.location_code).to eq ['mudd']
    end
  end

  context "with missing data" do
    let(:record2_path) { File.join(fixture_path, 'AC123_c99999.xml')}
    subject {
      f = File.open(record2_path)
      su = PulMetadataServices::PulfaRecord.new(f.read)
      f.close
      su
    }

    it "doesn't fail" do
      expect { subject.language }.not_to raise_error
    end

    it "returns nil for the missing fields" do
      expect(subject.language).to be nil
    end
  end
end
