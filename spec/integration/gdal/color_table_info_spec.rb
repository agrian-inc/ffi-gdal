# typed: false
# frozen_string_literal: true

require 'ffi-gdal'
require 'gdal'

RSpec.describe 'GDAL Color Table access', type: :integration do
  let(:dataset) { GDAL::Dataset.open(tmp_tiff, 'r') }
  let(:tmp_tiff) { make_temp_test_file(original_tiff) }
  after(:each) { dataset.close }

  subject(:color_table) do
    band = dataset.raster_band(1)
    band.color_table
  end

  context 'file with color table' do
    let(:original_tiff) do
      path = '../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif'
      File.expand_path(path, __dir__)
    end

    describe '#palette_interpretation' do
      subject { color_table.palette_interpretation }
      it { is_expected.to eq :GPI_RGB }
    end

    describe '#color_entry_count' do
      subject { color_table.color_entry_count }
      it { is_expected.to eq 256 }
    end

    describe '#color_entry' do
      it 'returns a GDAL::ColorEntry' do
        expect(subject.color_entry(0)).to be_a GDAL::ColorEntry
      end

      it 'has 4 Integer values, >= 0' do
        expect(subject.color_entry(0).color1).to eq 0
        expect(subject.color_entry(0).color2).to eq 0
        expect(subject.color_entry(0).color3).to eq 0
        expect(subject.color_entry(0).color4).to eq 255

        # 192 if GDAL 3; 191 if < 3
        expect(subject.color_entry(1).color1).to eq(191).or(eq(192))
        expect(subject.color_entry(1).color2).to eq 0
        expect(subject.color_entry(1).color3).to eq 0
        expect(subject.color_entry(1).color4).to eq 255
      end
    end

    describe '#color_entry_as_rgb' do
      it 'returns a GDAL::ColorEntry' do
        expect(subject.color_entry_as_rgb(0)).to be_a GDAL::ColorEntry
      end

      it 'has 4 Integer values, >= 0' do
        expect(subject.color_entry(0).color1).to eq 0
        expect(subject.color_entry(0).color2).to eq 0
        expect(subject.color_entry(0).color3).to eq 0
        expect(subject.color_entry(0).color4).to eq 255

        # 192 if GDAL 3; 191 if < 3
        expect(subject.color_entry(1).color1).to eq(191).or(eq(192))
        expect(subject.color_entry(1).color2).to eq 0
        expect(subject.color_entry(1).color3).to eq 0
        expect(subject.color_entry(1).color4).to eq 255
      end
    end
  end

  context 'file without color table' do
    let(:original_tiff) do
      path = '../../../spec/support/images/osgeo/geotiff/gdal_eg/cea.tif'
      File.expand_path(path, __dir__)
    end

    it { is_expected.to be_nil }
  end
end
