# typed: false
# frozen_string_literal: true

require 'ffi-gdal'
require 'gdal'

RSpec.describe 'Dataset Info', type: :integration do
  let(:tmp_tiff) { make_temp_test_file(original_tiff) }

  let(:original_tiff) do
    path = '../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif'
    File.expand_path(path, __dir__)
  end

  subject { GDAL::Dataset.open(tmp_tiff, 'r') }

  after { subject.close if File.exist?(tmp_tiff) }

  describe '#driver' do
    it 'is a GDAL::Driver' do
      expect(subject.driver).to be_a GDAL::Driver
    end
  end

  describe '#file_list' do
    it 'is a non-empty Array' do
      expect(subject.file_list).to be_an Array
    end

    it 'contains the file name' do
      expect(subject.file_list).to include(File.expand_path(tmp_tiff))
    end
  end

  describe '#flush_cache' do
    it 'is a GDAL::Driver' do
      expect { subject.flush_cache }.to_not raise_exception
    end
  end

  describe '#raster_x_size' do
    it 'is an Integer' do
      expect(subject.raster_x_size).to eq 101
    end
  end

  describe '#raster_y_size' do
    it 'is an Integer' do
      expect(subject.raster_y_size).to eq 101
    end
  end

  describe '#raster_count' do
    it 'is an Integer' do
      expect(subject.raster_count).to eq 1
    end
  end

  describe '#raster_band' do
    it 'each band is a GDAL::RasterBand' do
      1.upto(subject.raster_count) do |i|
        expect(subject.raster_band(i)).to be_a GDAL::RasterBand
      end
    end
  end

  describe '#projection' do
    it 'is a String' do
      expect(subject.projection).to be_a String
    end
  end

  describe '#projection=' do
    context 'param is an invalid projection string' do
      it 'raises a GDAL::Error' do
        expect { subject.projection = 'meow' }.to raise_exception(GDAL::Error)
      end
    end

    context 'param is an valid projection string' do
      let(:wkt) do
        <<~WKT.gsub("\n", '').gsub(/,\s+/, ',')
          GEOGCS["WGS 84",
            DATUM["WGS_1984",
              SPHEROID["WGS 84",6378137,298.257223563,
                  AUTHORITY["EPSG",7030]],
              TOWGS84[0,0,0,0,0,0,0],
              AUTHORITY["EPSG",6326]],
            PRIMEM["Greenwich",0,AUTHORITY["EPSG",8901]],
            UNIT["DMSH",0.0174532925199433,AUTHORITY["EPSG",9108]],
            AXIS["Lat",NORTH],
            AXIS["Long",EAST],
            AUTHORITY["EPSG",4326]]
        WKT
      end

      it 'sets the projection' do
        subject.projection = wkt
        expect(subject.projection).to start_with wkt[0..30]
      end
    end

    context 'param is not a string' do
      it 'raises a GDAL::Error' do
        expect { subject.projection = { one: 1 } }.to raise_exception(GDAL::Error)
      end
    end
  end

  describe '#access_flag' do
    it 'is GA_ReadOnly' do
      expect(subject.access_flag).to be :GA_ReadOnly
    end
  end

  describe '#add_band' do
    it 'raises a GDAL::UnsupportedOperation' do
      expect { subject.add_band(:GDT_Byte) }.to raise_exception(GDAL::UnsupportedOperation)
    end
  end

  describe '#create_mask_band' do
    context ':GMF_ALL_VALID' do
      it 'does not raise' do
        expect(subject.create_mask_band(:GMF_ALL_VALID)).to be_nil
      end
    end

    context ':GMF_PER_DATASET' do
      it 'does not raise' do
        expect(subject.create_mask_band(:GMF_PER_DATASET)).to be_nil
      end
    end

    context ':GMF_PER_ALPHA' do
      it 'does not raise' do
        expect(subject.create_mask_band(:GMF_PER_ALPHA)).to be_nil
      end
    end

    context ':GMF_NODATA' do
      it 'does not raise' do
        expect(subject.create_mask_band(:GMF_NODATA)).to be_nil
      end
    end

    context 'all flags' do
      it 'does not raise' do
        expect(subject.create_mask_band(:GMF_ALL_VALID, :GMF_PER_DATASET, :GMF_PER_ALPHA, :GMF_NODATA)).to be_nil
      end
    end
  end

  describe '#geo_transform' do
    it 'is a GDAL::GeoTransform' do
      expect(subject.geo_transform).to be_a GDAL::GeoTransform
    end
  end

  describe '#geo_transform=' do
    let(:geo_transform) { GDAL::GeoTransform.new }

    context 'read-only dataset' do
      it 'raises a GDAL::UnsupportedOperation' do
        expect { subject.geo_transform = geo_transform }.to raise_exception GDAL::UnsupportedOperation
      end
    end

    context 'writable dataset, param is a valid GeoTransform' do
      subject { GDAL::Dataset.open(tmp_tiff, 'w') }

      it 'returns the same GDAL::GeoTransform' do
        subject.geo_transform = geo_transform
        expect(subject.geo_transform).to eq geo_transform
      end
    end

    context 'writable dataset, param is a pointer to a valid GeoTransform' do
      subject { GDAL::Dataset.open(tmp_tiff, 'w') }

      it 'returns the same GDAL::GeoTransform' do
        subject.geo_transform = geo_transform.c_pointer
        expect(subject.geo_transform).to be_a GDAL::GeoTransform
      end
    end
  end

  describe '#gcp_count' do
    it 'is an Integer' do
      expect(subject.gcp_count).to be_a Integer
    end
  end

  describe '#gcp_projection' do
    it 'is a String' do
      expect(subject.gcp_projection).to be_a String
    end
  end

  describe '#gcps' do
    it 'is a GDALGCP' do
      expect(subject.gcps).to be_a FFI::GDAL::GCP
    end
  end

  describe '#build_overviews' do
    let(:ovr_file) { "#{tmp_tiff}.ovr" }
    after { File.unlink(ovr_file) if File.exist?(ovr_file) }

    context 'nearest neighbor resampling' do
      it 'creates an .ovr file with the same base name as the dataset file' do
        subject.build_overviews(:nearest, [2, 4, 8])
        expect(File.exist?(ovr_file)).to eq true
      end
    end

    context 'Gauss resampling' do
      it 'creates an .ovr file with the same base name as the dataset file' do
        subject.build_overviews(:gauss, [2, 4, 8])
        expect(File.exist?(ovr_file)).to eq true
      end
    end

    context 'Cubic resampling' do
      it 'creates an .ovr file with the same base name as the dataset file' do
        subject.build_overviews(:cubic, [2, 4, 8])
        expect(File.exist?(ovr_file)).to eq true
      end
    end

    context 'Average resampling' do
      it 'creates an .ovr file with the same base name as the dataset file' do
        subject.build_overviews(:average, [2, 4, 8])
        expect(File.exist?(ovr_file)).to eq true
      end
    end

    context 'Mode resampling' do
      it 'creates an .ovr file with the same base name as the dataset file' do
        subject.build_overviews(:mode, [2, 4, 8])
        expect(File.exist?(ovr_file)).to eq true
      end
    end

    context 'Average mag phase resampling' do
      it 'creates an .ovr file with the same base name as the dataset file' do
        subject.build_overviews(:average_magphase, [2, 4, 8])
        expect(File.exist?(ovr_file)).to eq true
      end
    end

    context 'no resampling' do
      it 'creates an .ovr file with the same base name as the dataset file' do
        subject.build_overviews(:none, [2, 4, 8])
        expect(File.exist?(ovr_file)).to eq true
      end
    end

    context 'unknown resampling algorithm' do
      it 'creates an .ovr file with the same base name as the dataset file' do
        expect { subject.build_overviews(:stuff, [2, 4, 8]) }
          .to raise_exception(GDAL::Error)
      end
    end
  end

  describe '#raster_io' do
    let(:write_buffer) do
      buffer = GDAL._buffer_from_data_type(:GDT_Byte, 2)
      buffer.write_array_of_uchar([1, 2])
    end

    let(:read_buffer) { GDAL._buffer_from_data_type(:GDT_Byte, 2) }

    context 'write to read-only dataset' do
      it 'raises a GDAL::Error when flushing the cache' do
        expect do
          subject.raster_io('w', write_buffer, x_size: 2, y_size: 1, band_numbers: [1])
          subject.flush_cache
        end.to raise_exception(GDAL::Error)
      end
    end

    context 'write using buffer that is too small for defaults' do
      subject { GDAL::Dataset.open(tmp_tiff, 'w') }

      it 'raises a GDAL::Error when flushing the cache' do
        expect do
          subject.raster_io('w', write_buffer)
          subject.flush_cache
        end.to raise_exception(GDAL::BufferTooSmall)
      end
    end

    context 'write to writable dataset' do
      subject { GDAL::Dataset.open(tmp_tiff, 'w') }

      it 'writes the data' do
        expect do
          subject.raster_io('w', write_buffer, x_size: 2, y_size: 1, band_numbers: [1])
          subject.flush_cache
        end.to_not raise_exception
      end
    end

    context 'read, buffer size too small' do
      it 'raises a GDAL::BufferTooSmall' do
        expect { subject.raster_io('r', read_buffer) }
          .to raise_exception GDAL::BufferTooSmall
      end
    end

    context 'read, giving params that fulfil buffer size requirements' do
      it 'reads the data' do
        subject.raster_io('r', read_buffer, x_size: 2, y_size: 1, band_numbers: [1])
        expect(read_buffer.read_array_of_uchar(2)).to eq [2, 2]
      end
    end
  end

  describe '#valid_min_buffer_size' do
    it 'returns the number of bytes for the GDT type * x buffer size * y buffer size' do
      expect(subject.send(:valid_min_buffer_size, :GDT_Float32, 3, 4)).to eq 48
    end
  end

  describe '#band_numbers_args' do
    context 'param is nil' do
      it 'returns no pointer and 0 band count' do
        pointer, count = subject.send(:band_numbers_args, nil)

        expect(pointer.size).to eq 0
        expect(pointer.type_size).to eq FFI::NativeType::INT32.size
        expect(count).to be_zero
      end
    end

    context 'param is an array of numbers' do
      it 'returns a pointer and the number of bands' do
        result_ptr, band_count = subject.send(:band_numbers_args, [3, 4, 5])
        expect(result_ptr).to be_a FFI::MemoryPointer
        expect(band_count).to eq 3
      end
    end
  end
end
