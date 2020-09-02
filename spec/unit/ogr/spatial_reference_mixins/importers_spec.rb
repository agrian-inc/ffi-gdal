# typed: false
# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  describe '#import_from_epsg' do
    context 'valid code' do
      it "updates self's info" do
        expect do
          subject.import_from_epsg(4326)
        end.to change { subject.to_wkt.size }.from(0)
      end

      it 'does not treat as lat/lon' do
        subject.import_from_epsg(4326)
        expect(subject.epsg_treats_as_lat_long?).to eq false
      end
    end

    context 'invalid code' do
      it 'raises a GDAL::UnsupportedOperation' do
        expect { subject.import_from_epsg 1_231_234 }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end

  describe '#import_from_epsga' do
    it "updates self's info" do
      expect do
        subject.import_from_epsga(4326)
      end.to change { subject.to_wkt.size }.from(0)
    end

    it 'treats as lat/lon' do
      subject.import_from_epsga(4326)
      expect(subject.epsg_treats_as_lat_long?).to eq true
    end
  end
end
