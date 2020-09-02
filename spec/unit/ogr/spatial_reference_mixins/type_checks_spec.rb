# typed: false
# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  describe '#geographic?' do
    context 'root is a GEOGCS node' do
      subject { described_class.new_from_epsg 4326 }
      it { is_expected.to be_geographic }
    end

    context 'root is not a GEOGCS node' do
      it { is_expected.to_not be_geographic }
    end
  end

  describe '#local?' do
    context 'root is a LOCAL_CS node' do
      subject do
        sr = described_class.new
        sr.local_cs = 'bobby'
        sr
      end

      it { is_expected.to be_local }
    end

    context 'root is not a LOCAL_CS node' do
      it { is_expected.to_not be_local }
    end
  end

  describe '#projected?' do
    context 'contains a PROJCS node' do
      subject do
        sr = described_class.new
        sr.proj_cs = 'bobby'
        sr
      end

      it { is_expected.to be_projected }
    end

    context 'does not contain a PROJCS node' do
      it { is_expected.to_not be_projected }
    end
  end

  describe '#compound?' do
    context 'contains a COMPD_CS node' do
      subject do
        sr = described_class.new_from_epsg(4326)
        sr.set_vert_cs('darrel', 'bobby', 2005)
        sr
      end

      it { is_expected.to be_compound }
    end

    context 'does not contain a COMPD_CS node' do
      it { is_expected.to_not be_compound }
    end
  end

  describe '#geocentric?' do
    context 'contains a GEOCCS node' do
      subject do
        sr = described_class.new
        sr.geoc_cs = 'bobby'
        sr
      end

      it { is_expected.to be_geocentric }
    end

    context 'does not contain a GEOCCS node' do
      it { is_expected.to_not be_geocentric }
    end
  end

  describe '#vertical?' do
    context 'contains a VERT_CS node' do
      subject do
        sr = described_class.new
        sr.set_vert_cs('darrel', 'bobby', 2005)
        sr
      end

      it { is_expected.to be_vertical }
    end

    context 'does not contain a VERT_CS node' do
      it { is_expected.to_not be_vertical }
    end
  end

  describe '#same?' do
    context 'SpatialReferences describe the same system' do
      subject { described_class.new_from_epsg(4322) }
      let(:other) { described_class.new_from_epsg(4322) }
      it('returns true') { expect(subject.same?(other)).to eq true }
    end

    context 'SpatialReferences describe different systems' do
      subject { described_class.new_from_epsg(4322) }
      let(:other) { described_class.new_from_epsg(4326) }
      it('returns false') { expect(subject.same?(other)).to eq false }
    end
  end

  describe '#geog_cs_is_same?' do
    context 'SpatialReferences describe the same GEOGCS system' do
      subject { described_class.new_from_epsg(4322) }
      let(:other) { described_class.new_from_epsg(4322) }
      it('returns true') { expect(subject.geog_cs_is_same?(other)).to eq true }
    end

    context 'SpatialReferences describe different systems' do
      subject { described_class.new_from_epsg(4322) }
      let(:other) { described_class.new_from_epsg(4326) }
      it('returns false') { expect(subject.geog_cs_is_same?(other)).to eq false }
    end
  end

  describe '#vert_cs_is_same?' do
    context 'SpatialReferences describe the same VERT_CS system' do
      subject do
        sr = described_class.new
        sr.set_vert_cs('one', 'things', 2005)
        sr
      end

      let(:other) do
        sr = described_class.new
        sr.set_vert_cs('one', 'things', 2005)
        sr
      end

      it('returns true') { expect(subject.vert_cs_is_same?(other)).to eq true }
    end

    context 'SpatialReferences describe different systems' do
      subject do
        sr = described_class.new
        sr.set_vert_cs('one', 'things', 2005)
        sr
      end

      let(:other) do
        sr = described_class.new
        sr.set_vert_cs('two', 'other things', 2006)
        sr
      end

      it('returns false') { expect(subject.vert_cs_is_same?(other)).to eq false }
    end
  end
end
