# typed: false
# frozen_string_literal: true

require 'ffi-gdal'
require 'gdal'

RSpec.describe 'Driver Info', type: :integration do
  # Without this before block, tests fail--seemingly due to too many instances
  # of the same driver open. Seems like there might be a better solution than
  # this here, but I'm not sure what it is yet.
  before { ::FFI::GDAL::GDAL.GDALAllRegister }
  let(:tmp_source_tiff) { make_temp_test_file(original_source_tiff) }

  let(:original_source_tiff) do
    path = '../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif'
    File.expand_path(path, __dir__)
  end

  subject { GDAL::Driver.by_name 'GTiff' }

  it_behaves_like 'a major object'

  describe '.count' do
    it 'is a non-zero Integer' do
      expect(GDAL::Driver.count).to be_a Integer
      expect(GDAL::Driver.count).to be_positive
    end
  end

  describe '#c_pointer' do
    it 'is a FFI::Pointer to the actual C driver' do
      expect(subject.c_pointer).to be_a FFI::Pointer
      expect(subject.c_pointer).to_not be_null
    end
  end

  describe '#short_name' do
    it 'is GTiff' do
      expect(subject.short_name).to eq 'GTiff'
    end
  end

  describe '#long_name' do
    it 'is GeoTiff' do
      expect(subject.long_name).to eq 'GeoTIFF'
    end
  end

  describe '#help_topic' do
    it 'is http://gdal.org/frmt_gtiff.html' do
      expect(subject.help_topic).to match %r{http://gdal.org/\S+gtiff.html}
    end
  end

  describe '#creation_option_list' do
    it 'is an Array of Hashes' do
      expect(subject.creation_option_list).to be_an Array
      expect(subject.creation_option_list.first).to be_a Hash
    end
  end

  describe '#validate_creation_options' do
    context 'valid options for the driver' do
      let(:options) do
        {
          'COMPRESS' => 'JPEG',
          'JPEG_QUALITY' => 90,
          'INTERLEAVE' => 'BAND'
        }
      end

      it 'returns true' do
        expect(subject.validate_creation_options(options)).to eq true
      end
    end

    context 'invalid options for the driver' do
      let(:options) do
        { 'THINGS' => 123 }
      end

      it 'returns false' do
        expect(subject.validate_creation_options(options)).to eq false
      end
    end
  end

  describe '#copy_dataset_files' do
    let(:dest_tiff) { File.expand_path('copied_tiff.tif', 'tmp') }
    after { File.unlink(dest_tiff) if File.exist?(dest_tiff) }

    context 'source is a GTiff' do
      it 'copies the file' do
        subject.copy_dataset_files(tmp_source_tiff, dest_tiff)
        expect(File.exist?(dest_tiff)).to eq true
      end
    end

    context 'source is of a different file type than the driver supports' do
      let(:source_file) { __FILE__ }

      it 'copies the file' do
        expect { subject.copy_dataset_files(source_file, dest_tiff) }
          .to raise_exception(GDAL::OpenFailure)
      end
    end
  end

  describe '#create_dataset' do
    let(:new_dataset_path) { 'tmp/driver_create_dataset.tif' }
    after { File.unlink(new_dataset_path) if File.exist?(new_dataset_path) }

    it 'creates a dataset' do
      dataset = subject.create_dataset(new_dataset_path, 2, 2)

      expect(File.exist?(new_dataset_path)).to eq true
      expect(dataset).to be_a GDAL::Dataset
      expect(dataset.raster_x_size).to eq 2
      expect(dataset.raster_y_size).to eq 2
    end
  end

  describe '#copy_dataset' do
    let(:copy_dataset_path) { 'tmp/driver_copy_dataset.tif' }
    let(:source_dataset) { GDAL::Dataset.open(tmp_source_tiff, 'r') }
    after { source_dataset.close }

    it 'copies the dataset and yields a GDAL::Dataset' do
      subject.copy_dataset(source_dataset, copy_dataset_path) do |dest_dataset|
        expect(dest_dataset).to be_a GDAL::Dataset
        expect(dest_dataset.driver.short_name).to eq 'GTiff'
        expect(dest_dataset.access_flag).to eq :GA_Update
      end

      expect(File.exist?(copy_dataset_path)).to eq true
    end
  end

  describe '#delete_dataset' do
    context 'dataset exists' do
      it 'removes the related files' do
        expect { subject.delete_dataset(tmp_source_tiff) }
          .to change { File.exist?(tmp_source_tiff) }.from(true).to(false)
      end
    end

    context 'dataset does not exist' do
      it 'removes the related files' do
        expect { subject.delete_dataset('meow.tif') }.to raise_exception(GDAL::OpenFailure)
      end
    end
  end

  describe 'rename_dataset' do
    context 'dataset exists' do
      after { File.unlink('tmp/meow.tif') if File.exist?('tmp/meow.tif') }

      it 'removes the related files' do
        expect { subject.rename_dataset(tmp_source_tiff, 'tmp/meow.tif') }
          .to change { File.exist?('tmp/meow.tif') }.from(false).to(true)
      end
    end

    context 'dataset does not exist' do
      it 'removes the related files' do
        expect { subject.rename_dataset('meow1.tif', 'meow2.tif') }.to raise_exception(GDAL::OpenFailure)
      end
    end
  end
end
