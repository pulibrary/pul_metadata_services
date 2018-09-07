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
        title: ['19th Century Catalog and Correspondence, Pre-Vinton, 1811-'],
        created: ['1865-01-01T00:00:00Z/1865-12-31T23:59:59Z'],
        creator: ['Princeton University. Library. Dept. of Rare Books and Special Collections'],
        publisher: ['Princeton University. Library. Dept. of Rare Books and Special Collections'],
        memberOf: [{title: 'Princeton University Library Records', identifier: 'AC123'}],
        date_created: ['circa 1865'],
        container: ['Box 1, Folder 2'],
        extent: ['1 folder'],
        heldBy: ['mudd'],
        language: ['eng']
      }
      expect(subject.attributes).to eq expected
    end
  end

  describe '#collection?' do
    it "knows it's not a collection" do
      expect(subject.collection?).to be false
    end
  end

  context "with missing data" do
    let(:record2_path) { File.join(fixture_path, 'AC057_c18.xml')}
    subject {
      f = File.open(record2_path)
      su = PulMetadataServices::PulfaRecord.new(f.read)
      f.close
      su
    }

    describe "#attributes" do
      it "doesn't fail" do
        expect { subject.attributes }.not_to raise_error
      end

      it "returns nil for the missing fields" do
        expect(subject.attributes[:language]).to be nil
        expect(subject.attributes[:container]).to eq ["Box 2"]
      end
    end
  end

  context "with DSC container approach" do
    let(:record2_path) { File.join(fixture_path, 'C0967_c0001.xml')}
    subject {
      f = File.open(record2_path)
      su = PulMetadataServices::PulfaRecord.new(f.read)
      f.close
      su
    }

    describe '#attributes' do
      it 'works' do
        expected = {
          title: ['Abdura Makedonias'],
          creator: ['Lampakēs, Geōrgios, 1854-1914.'],
          publisher: ['Lampakēs, Geōrgios, 1854-1914.'],
          created: ['1902-01-01T00:00:00Z/1902-12-31T23:59:59Z'],
          date_created: ['1902'],
          memberOf: [{title: 'Byzantine and post-Byzantine Inscriptions Collection', identifier: 'C0967'}],
          container: ['Box 1, Folder 1'],
          extent: ['1 folder'],
          heldBy: ['mss'],
          language: ['gre']
        }
        expect(subject.attributes).to eq expected
      end
    end
  end

  context 'collection record' do
  let(:record1_path) { File.join(fixture_path, 'C0652.xml')}

    it "knows it's a collection" do
      expect(subject.collection?).to be true
    end

    describe '#attributes' do
      it 'returns attributes hash' do
        expected = {
          title: ['Emir Rodriguez Monegal Papers'],
          created: ['1941-01-01T00:00:00Z/1985-12-31T23:59:59Z'],
          date_created: ['1941-1985'],
          extent: ['11 linear feet'],
          heldBy: ['mss'],
          language: ['spa']
        }
        expect(subject.attributes).to eq expected
      end
    end
  end
end
