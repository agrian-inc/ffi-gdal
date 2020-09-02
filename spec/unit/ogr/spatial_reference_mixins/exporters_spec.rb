# typed: false
# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  describe '#to_erm' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a Hash' do
        expect(subject.to_erm).to eq(projection_name: 'GEODETIC', datum_name: 'WGS72DOD', units: 'METERS')
      end
    end

    context 'empty SRS' do
      it 'raises an OGR::UnsupportedSRS' do
        expect { subject.to_erm }.to raise_exception OGR::UnsupportedSRS
      end
    end
  end

  describe '#to_mapinfo' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns the string' do
        expect(subject.to_mapinfo).to start_with 'Earth Projection'
      end
    end

    context 'empty SRS' do
      it 'returns a "NonEarth Units" message' do
        expect(subject.to_mapinfo).to start_with 'NonEarth Units'
      end
    end
  end

  describe '#to_pci' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a Hash' do
        expect(subject.to_pci).to eq(
          projection: 'LONG/LAT    D001',
          units: 'DEGREE',
          projection_parameters: []
        )
      end
    end

    context 'empty SRS' do
      it 'returns default values' do
        expect(subject.to_pci).to eq(
          projection: 'LONG/LAT    E012',
          units: 'DEGREE',
          projection_parameters: []
        )
      end
    end
  end

  describe '#to_proj4' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a PROJ4 String' do
        expect(subject.to_proj4.strip)
          .to eq('+proj=longlat +ellps=WGS72 +towgs84=0,0,4.5,0,0,0.554,0.2263 +no_defs')
      end
    end

    context 'empty SRS' do
      it 'raises a GDAL::UnsupportedOperation' do
        expect { subject.to_proj4 }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end

  describe '#to_wkt' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a well-known text String' do
        expect(subject.to_wkt).to start_with 'GEOGCS["WGS 72",DATUM["'
      end
    end

    context 'empty SRS' do
      it 'returns an empty String' do
        expect(subject.to_wkt).to eq ''
      end
    end
  end

  describe '#to_pretty_wkt' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns a formatted well-known text String' do
        expect(subject.to_wkt).to start_with %(GEOGCS["WGS 72",DATUM[")
      end
    end

    context 'empty SRS' do
      it 'returns an empty String' do
        expect(subject.to_pretty_wkt).to be_empty
      end
    end
  end

  describe '#to_xml' do
    context 'known projection' do
      subject { described_class.new_from_epsg(4322) }

      it 'returns an XML string' do
        expect(subject.to_xml).to start_with '<gml:GeographicCRS gml:id="ogrcrs1">'
      end
    end

    context 'empty SRS' do
      it 'raises an OGR::UnsupportedSRS' do
        expect { subject.to_xml }.to raise_exception OGR::UnsupportedSRS
      end
    end
  end

  describe '#to_gml' do
    it { is_expected.to respond_to :to_gml }
  end
end
