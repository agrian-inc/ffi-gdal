# typed: false
# frozen_string_literal: true

require 'ffi-gdal'
require 'gdal'

RSpec.describe 'Raster Attribute Table Info', type: :integration do
  let(:file) { make_temp_test_file(original_source_tiff) }

  let(:original_source_tiff) do
    path = '../../../spec/support/images/osgeo/gdal/data/hfa/float-rle.img'
    File.expand_path(path, __dir__)
  end

  let(:dataset) { GDAL::Dataset.open(file, 'r') }
  after { dataset.close }

  subject do
    band = dataset.raster_band(1)
    band.default_raster_attribute_table
  end

  describe '#changes_written_to_file?' do
    context 'no changes to file' do
      it 'is true' do
        expect(subject.changes_written_to_file?).to eq true
      end
    end
  end

  describe '#column_count' do
    it 'retrieves the column count' do
      expect(subject.column_count).to eq 1
    end
  end

  describe '#column_name' do
    it 'retrieves the column name' do
      expect(subject.column_name(0)).to eq 'Histogram'
    end
  end

  describe '#column_usage' do
    it 'retrieves the column usage' do
      expect(subject.column_usage(0)).to eq :GFU_PixelCount
    end
  end

  describe '#column_type' do
    context 'column number exists' do
      it 'retrieves the column type' do
        expect(subject.column_type(0)).to eq :GFT_Real
      end
    end

    context 'column number does not exist' do
      it 'returns :GFT_Integer' do
        expect(subject.column_type(110)).to eq :GFT_Integer
      end
    end
  end

  describe '#column_of_usage' do
    context 'column with usage type exists' do
      it 'retrieves the index of column' do
        expect(subject.column_of_usage(:GFU_PixelCount)).to eq 0
      end
    end

    context 'column with usage type does not exist' do
      it 'returns nil' do
        expect(subject.column_of_usage(:GFU_Name)).to be_nil
      end
    end

    context 'column with invalid usage type' do
      it 'returns nil' do
        expect { subject.column_of_usage(:GFU_Meow) }.to raise_exception ArgumentError
      end
    end
  end

  describe '#create_column' do
    context 'valid params, dataset not opened in write mode' do
      it 'raises a GDAL::NoWriteAccess' do
        expect { subject.create_column('things', :GFT_String, :GFU_Name) }
          .to raise_exception GDAL::NoWriteAccess
      end
    end

    context 'valid params' do
      let(:dataset) { GDAL::Dataset.open(file, 'w') }

      it 'adds the column' do
        subject.create_column('things', :GFT_Integer, :GFU_Red)
        expect(subject.column_name(1)).to eq 'Red'
        expect(subject.column_usage(1)).to eq :GFU_Red
        expect(subject.column_type(1)).to eq :GFT_Integer
      end
    end
  end

  describe '#row_count' do
    it 'returns the number of rows' do
      expect(subject.row_count).to eq 256
    end
  end

  describe '#row_count=' do
    context 'dataset not opened in write mode' do
      it 'raises a GDAL::NoWriteAccess' do
        expect { subject.row_count = 1 }.to raise_exception GDAL::NoWriteAccess
      end
    end

    context 'dataset opened in write mode' do
      let(:dataset) { GDAL::Dataset.open(file, 'w') }

      it 'sets the number of rows' do
        subject.row_count = 2
        expect(subject.row_count).to eq 2
      end
    end
  end

  describe '#row_of_value' do
    context 'a row exists for the given pixel value' do
      it 'returns the row index' do
        expect(subject.row_of_value(58_595)).to eq 253
      end
    end

    context 'a row does not exist for the given pixel value' do
      it 'returns nil' do
        expect(subject.row_of_value(123_456)).to eq nil
      end
    end
  end

  describe '#set_value_as_string' do
    context 'dataset not opened in write mode' do
      it 'raises a GDAL::NoWriteAccess' do
        expect { subject.set_value_as_string(0, 0, 'test') }.to raise_exception GDAL::NoWriteAccess
      end
    end

    context 'column is a double' do
      let(:dataset) { GDAL::Dataset.open(file, 'w') }

      it 'sets the value' do
        subject.set_value_as_string(0, 0, 'test')
        expect(subject.value_as_string(0, 0)).to eq '0'
      end
    end
  end

  describe '#set_value_as_double' do
    context 'dataset not opened in write mode' do
      it 'raises a GDAL::NoWriteAccess' do
        expect { subject.set_value_as_double(0, 0, 1.2) }.to raise_exception GDAL::NoWriteAccess
      end
    end

    context 'column is a double' do
      let(:dataset) { GDAL::Dataset.open(file, 'w') }

      it 'sets the value' do
        subject.set_value_as_double(0, 0, 1.2)
        expect(subject.value_as_double(0, 0)).to eq 1.2
      end
    end
  end

  describe '#set_value_as_integer' do
    context 'dataset not opened in write mode' do
      it 'raises a GDAL::NoWriteAccess' do
        expect { subject.set_value_as_integer(0, 0, 1) }.to raise_exception GDAL::NoWriteAccess
      end
    end

    context 'column is a double' do
      let(:dataset) { GDAL::Dataset.open(file, 'w') }

      it 'sets the value' do
        subject.set_value_as_integer(0, 0, 1)
        expect(subject.value_as_integer(0, 0)).to eq 1
      end
    end
  end

  describe '#linear_binning' do
    it 'returns a Hash that contains binning info' do
      expect(subject.linear_binning).to eq(row_0_minimum: 0.0, bin_size: 230.79607843137254)
    end
  end

  describe '#set_linear_binning' do
    context 'dataset not opened in write mode' do
      it 'raises a GDAL::NoWriteAccess' do
        expect { subject.set_linear_binning(0, 0) }.to raise_exception GDAL::NoWriteAccess
      end
    end

    context 'valid binning params' do
      let(:dataset) { GDAL::Dataset.open(file, 'w') }

      it 'returns a Hash that contains binning info' do
        subject.set_linear_binning(1, 20)
        expect(subject.linear_binning).to eq(row_0_minimum: 1.0, bin_size: 20.0)
      end
    end
  end

  describe '#to_color_table' do
    it 'returns nil' do
      expect(subject.to_color_table).to be_nil
    end
  end

  describe '#dump_readable' do
    let(:output_path) { File.expand_path('tmp/raster_attribute_table_info') }
    after { File.unlink(output_path) if File.exist?(output_path) }

    it 'writes to the file' do
      subject.dump_readable(output_path)
      expect(File.exist?(output_path)).to eq true
    end
  end
end
