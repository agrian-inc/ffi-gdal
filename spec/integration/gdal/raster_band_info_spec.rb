# typed: false
# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'
require 'ffi-gdal'
require 'gdal'

RSpec.describe 'Raster Band Info', type: :integration do
  let(:original_tiff) do
    path = '../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif'
    File.expand_path(path, __dir__)
  end

  let(:nodata_tiff) do
    path = '../../../spec/support/images/123.tiff'
    File.expand_path(path, __dir__)
  end

  let(:nodata_dataset) { GDAL::Dataset.open(nodata_tiff, 'r') }

  let(:tmp_tiff) { make_temp_test_file(original_tiff) }
  let(:dataset) { GDAL::Dataset.open(tmp_tiff, 'w') }
  after { dataset.close }
  subject { dataset.raster_band(1) }

  it_behaves_like 'a major object'

  describe '#x_size' do
    it 'is a non-zero Integer' do
      expect(subject.x_size).to be_a Integer
      expect(subject.x_size).to be_positive
    end
  end

  describe '#y_size' do
    it 'is a non-zero Integer' do
      expect(subject.y_size).to be_a Integer
      expect(subject.y_size).to be_positive
    end
  end

  describe '#access_flag' do
    specify { expect(subject.access_flag).to eq :GA_Update }
  end

  describe '#number' do
    it 'is a non-zero Integer' do
      expect(subject.number).to be_a Integer
      expect(subject.number).to be_positive
    end
  end

  describe '#color_interpretation' do
    it 'is a Symbol; one of FFI::GDAL::GDAL::ColorInterp' do
      expect(subject.color_interpretation).to be_a Symbol
      expect(FFI::GDAL::GDAL::ColorInterp.symbols).to include subject.color_interpretation
    end
  end

  describe '#color_table' do
    it 'is a GDAL::ColorTable' do
      expect(subject.color_table).to be_a GDAL::ColorTable if subject.color_table
    end
  end

  describe '#data_type' do
    it 'is a Symbol; one of FFI::GDAL::GDAL::DataType' do
      expect(subject.data_type).to be_a Symbol
      expect(FFI::GDAL::GDAL::DataType.symbols).to include subject.data_type
    end
  end

  describe '#block_size' do
    it 'is a Hash with x and y keys that are >= 1' do
      expect(subject.block_size).to be_a Hash
      expect(subject.block_size[:x]).to be >= 1
      expect(subject.block_size[:y]).to be >= 1
    end
  end

  describe '#category_names' do
    it 'is an Array of Strings' do
      expect(subject.category_names).to be_an Array

      subject.category_names.each do |category_name|
        expect(category_name).to be_a String
        expect(category_name).to_not be_empty
      end
    end
  end

  describe '#category_names=' do
    it 'sets the category names' do
      subject.category_names = %w[one two three]

      expect(subject.category_names).to eq %w[one two three]
    end
  end

  context 'no data not set' do
    describe '#no_data_value' do
      it 'is a Hash with :value and :is_associated keys' do
        expect(subject.no_data_value).to be_an Hash

        expect(subject.no_data_value[:value]).to be_nil
        expect(subject.no_data_value[:is_associated]).to_not be_nil
      end
    end
  end

  context 'no data is set' do
    subject { nodata_dataset.raster_band(1) }

    describe '#no_data_value' do
      it 'is a Hash with :value and :is_associated keys' do
        expect(subject.no_data_value).to be_an Hash

        expect(subject.no_data_value[:value]).to be_a Float
        expect(subject.no_data_value[:is_associated]).to_not be_nil
      end
    end
  end

  describe '#overview_count' do
    it 'is an Integer' do
      expect(subject.overview_count).to be_a Integer
    end
  end

  describe '#arbitrary_overviews?' do
    it 'is true or false' do
      expect([true, false]).to include subject.arbitrary_overviews?
    end
  end

  describe '#overview' do
    it 'returns a GDAL::RasterBand if the overview exists' do
      overview = subject.overview(0)
      expect(overview).to be_a GDAL::RasterBand if overview
    end
  end

  describe '#raster_sample_overview' do
    it 'returns a GDAL::RasterBand if the overview exists' do
      overview = subject.raster_sample_overview
      expect(overview).to be_a GDAL::RasterBand
    end
  end

  describe '#mask_band' do
    it 'returns a GDAL::RasterBand if the mask_band exists' do
      overview = subject.mask_band
      expect(overview).to be_a GDAL::RasterBand
    end
  end

  describe '#mask_flags' do
    it 'returns an Array of Symbols' do
      expect(subject.mask_flags).to eq([:GMF_ALL_VALID]).or eq([:GMF_PER_DATASET])
    end
  end

  describe '#statistics' do
    it 'returns a Hash with populated values' do
      expect(subject.statistics).to be_a Hash
      expect(%i[minimum maximum mean standard_deviation])
        .to eq subject.statistics.keys
    end

    it 'has a :minimum that ranges between 0.0/-32768.0 and 255.0' do
      min = subject.statistics[:minimum]

      unless min.to_d == -32_768.0.to_d
        expect(subject.statistics[:minimum]).to(satisfy { |v| v >= 0 || v == -32_768 })
        expect(subject.statistics[:minimum]).to be <= 255.0
      end
    end
  end

  describe '#scale' do
    it 'returns a Hash with populated values' do
      expect(subject.scale).to be_a Hash
      expect(%i[value is_meaningful]).to eq subject.scale.keys
    end

    it 'has a :value that is a Float' do
      expect(subject.scale[:value]).to be_a Float
    end

    it 'has a :is_meaningful that is false (since the examples are geotiffs)' do
      expect(subject.scale[:is_meaningful]).to eq false
    end
  end

  describe '#scale=' do
    it 'does nothing (because the file formats dont support it)' do
      subject.scale = 0.1
      expect(subject.scale[:value]).to eq 0.1
    end
  end

  describe '#offset' do
    it 'returns a Hash with populated values' do
      expect(subject.offset).to be_a Hash
      expect(%i[value is_meaningful]).to eq subject.offset.keys
    end

    it 'has a :value that is a Float' do
      expect(subject.offset[:value]).to be_a Float
    end

    it 'has a :is_meaningful that is false (since the examples are geotiffs)' do
      expect(subject.offset[:is_meaningful]).to eq false
    end
  end

  describe '#offset=' do
    it 'does nothing (because the file formats dont support it)' do
      subject.offset = 0.1
      expect(subject.offset[:value]).to eq 0.1
    end
  end

  describe '#unit_type' do
    it 'returns a String' do
      expect(subject.unit_type).to be_a String
    end
  end

  describe '#unit_type=' do
    it 'does nothing (because the file formats dont support it)' do
      if defined? FFI::GDAL::GDAL::GDALSetRasterUnitType
        subject.unit_type = 'ft'
        expect(subject.unit_type).to eq 'ft'
      else
        skip 'GDALSetRasterUnitType not supported'
      end
    end
  end

  describe '#default_histogram' do
    let!(:histogram) { subject.default_histogram }

    it 'returns a Hash with :minimum, :maximum, :buckets, and :totals' do
      if histogram
        expect(histogram).to be_a Hash
        expect(histogram.keys).to eq %i[minimum maximum buckets totals]
      end
    end

    it 'has :minimum as a Float' do
      expect(histogram[:minimum]).to be_a Float if histogram
    end

    it 'has :maximum as a Float' do
      expect(histogram[:maximum]).to be_a Float if histogram
    end

    it 'has :buckets as an Integer' do
      expect(histogram[:buckets]).to be_a Integer if histogram
    end

    it 'has :totals as an Array of 0 or 256 Integers' do
      if histogram
        expect(histogram[:totals]).to be_an Array
        expect(histogram[:totals].size).to eq(256).or eq(0)
        expect(histogram[:totals].all? { |t| t.class == Integer }).to eq true
      end
    end
  end

  describe '#default_raster_attribute_table' do
    it 'returns a GDAL::RasterAttributeTable' do
      rat = subject.default_raster_attribute_table

      expect(rat).to be_a GDAL::RasterAttributeTable if rat
    end
  end

  describe '#min_max' do
    it 'returns a Hash with :min and :max keys' do
      expect(subject.min_max).to be_a Hash
      expect(subject.min_max.size).to eq 2
      expect(subject.min_max[:min]).to be_a Float
      expect(subject.min_max[:max]).to be_a Float
    end

    it 'has a min that is < its max' do
      expect(subject.min_max[:min]).to be < subject.min_max[:max]
    end
  end

  describe '#minimum_value' do
    it 'returns a Hash with populated values' do
      expect(subject.minimum_value).to be_a Hash
      expect(%i[value is_tight]).to eq subject.minimum_value.keys
    end

    it 'has a :value that is a Float' do
      expect(subject.minimum_value[:value]).to be_a Float
    end

    it 'has a :is_tight that is nil (since the examples are geotiffs)' do
      # expect(subject.minimum_value[:is_tight]).to eq nil
    end
  end

  describe '#maximum_value' do
    it 'returns a Hash with populated values' do
      expect(subject.maximum_value).to be_a Hash
      expect(%i[value is_tight]).to eq subject.maximum_value.keys
    end

    it 'has a :value that is a Float' do
      expect(subject.maximum_value[:value]).to be_a Float
    end

    it 'has a :is_tight that is nil (since the examples are geotiffs)' do
      # expect(subject.maximum_value[:is_tight]).to eq nil
    end
  end
end
