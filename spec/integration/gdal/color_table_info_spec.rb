require 'spec_helper'
require 'support/integration_help'
require 'ffi-gdal'
require 'gdal/dataset'

TIF_FILES.each do |file|
  dataset =  GDAL::Dataset.open(file, 'r')

  RSpec.describe 'Color Table Info' do
    after :all do
      dataset.close
    end

    # TODO: Test against each raster band
    subject do
      band = dataset.raster_band(1)
      band.color_table
    end

    describe '#palette_interpretation' do
      it 'returns a GDALPaletteInterp' do
        next if subject.nil?

        expect(subject.palette_interpretation).to eq :GPI_RGB
      end
    end

    describe '#color_entry_count' do
      it 'returns a Fixnum (256 with current test files)' do
        next if subject.nil?

        expect(subject.color_entry_count).to eq 256
      end
    end

    describe '#color_entry' do
      it 'returns a GDAL::ColorEntry' do
        next if subject.nil?

        expect(subject.color_entry(0)).to be_a GDAL::ColorEntry
      end

      it 'has 4 Fixnum values, >= 0' do
        next if subject.nil?

        expect(subject.color_entry(0).color1).to be_a Fixnum
        expect(subject.color_entry(0).color1).to be >= 0

        expect(subject.color_entry(0).color2).to be_a Fixnum
        expect(subject.color_entry(0).color2).to be >= 0

        expect(subject.color_entry(0).color3).to be_a Fixnum
        expect(subject.color_entry(0).color3).to be >= 0

        expect(subject.color_entry(0).color4).to be_a Fixnum
        expect(subject.color_entry(0).color4).to be >= 0
      end
    end
  end
end
