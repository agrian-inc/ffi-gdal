# typed: false
# frozen_string_literal: true

require 'gdal/dataset'

RSpec.describe GDAL::Dataset do
  let(:file_path) do
    File.expand_path('../../support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif', __dir__)
  end

  subject do
    described_class.open(file_path, 'r', shared: false)
  end

  it_behaves_like 'a major object'

  describe '.open' do
    context 'not a dataset' do
      it 'raises an GDAL::OpenFailure' do
        expect do
          described_class.open('blarg', 'r')
        end.to raise_exception GDAL::OpenFailure
      end
    end

    context 'block given' do
      let(:dataset) { instance_double 'GDAL::Dataset' }

      it 'yields then closes the opened DataSource' do
        allow(described_class).to receive(:new).and_return dataset

        expect(dataset).to receive(:close)
        expect { |b| described_class.open('blarg', 'r', &b) }
          .to yield_with_args(dataset)
      end
    end
  end

  describe '.copy_whole_raster' do
    it "doesn't blow up" do
      destination = GDAL::Driver
                    .by_name('MEM')
                    .create_dataset('testy', subject.raster_x_size, subject.raster_y_size,
                                    band_count: subject.raster_count, data_type: subject.raster_band(1).data_type)
      described_class.copy_whole_raster(subject, destination)
    end
  end

  describe '#access_flag' do
    it 'returns the flag that was used to open the dataset' do
      expect(subject.access_flag).to eq :GA_ReadOnly
    end
  end

  describe '#driver' do
    it 'returns the driver that was used to open the dataset' do
      expect(subject.driver).to be_a GDAL::Driver
    end
  end

  describe '#file_list' do
    it 'returns an array that includes the file that represents the dataset' do
      expect(subject.file_list).to be_an Array
      expect(subject.file_list).to include(file_path)
    end
  end

  describe '#flush_cache' do
    it 'returns nil' do
      expect(subject.flush_cache).to be_nil
    end
  end

  describe '#raster_x_size' do
    it 'returns an Integer' do
      expect(subject.raster_x_size).to eq 101
    end
  end

  describe '#raster_y_size' do
    it 'returns an Integer' do
      expect(subject.raster_y_size).to eq 101
    end
  end

  describe '#raster_count' do
    it 'returns an Integer' do
      expect(subject.raster_count).to eq 1
    end
  end

  describe '#raster_band' do
    it 'returns a GDAL::RasterBand' do
      expect(subject.raster_band(1)).to be_a GDAL::RasterBand
    end
  end

  describe '#add_band' do
    it 'raises a GDAL::UnsupportedOperation' do
      expect { subject.add_band(:GDT_Byte) }.to raise_exception(GDAL::UnsupportedOperation)
    end
  end

  describe '#create_mask_band' do
    context 'no flags given' do
      it 'returns nil' do
        expect(subject.create_mask_band(0)).to be_nil
      end
    end
  end

  describe '#projection' do
    let(:expected_wkt) do
      'GEOGCS["unknown",DATUM["unknown",SPHEROID["Bessel 1841",' \
        '6377397.155,299.1528128000033,AUTHORITY["EPSG","7004"]],' \
        'TOWGS84[598.1,73.7,418.2,0.202,0.045,-2.455,6.7]],' \
        'PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]]'
    end

    it 'returns the projection string' do
      expect(subject.projection).to start_with 'GEOGCS["unknown",DATUM["'
    end
  end

  describe '#projection=' do
    context 'good projection' do
      it 'sets the new projection' do
        proj = subject.projection
        expect(subject.projection = proj).to eq proj
        expect(subject.projection).to eq proj
      end
    end

    context 'bad projection' do
      it do
        expect { subject.projection = 'meow' }.to raise_exception(GDAL::Error)
      end
    end
  end

  describe '#geo_transform' do
    it 'returns a GDAL::GeoTransform' do
      expect(subject.geo_transform).to be_a GDAL::GeoTransform
    end
  end

  describe '#parse_mask_flag_symbols' do
    context 'empty params' do
      it 'returns 0' do
        expect(subject.send(:parse_mask_flag_symbols, nil)).to eq 0
      end
    end

    context ':GMF_ALL_VALID' do
      it 'returns 1' do
        expect(subject.send(:parse_mask_flag_symbols, :GMF_ALL_VALID)).to eq 1
      end
    end

    context ':GMF_ALL_VALID, :GMF_NODATA' do
      it 'returns 1' do
        expect(subject.send(:parse_mask_flag_symbols, :GMF_ALL_VALID, :GMF_NODATA)).to eq 9
      end
    end
  end
end
