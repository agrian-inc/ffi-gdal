# typed: true
# frozen_string_literal: true

require 'multi_xml'
require 'sorbet-runtime'
require_relative '../gdal'
require_relative 'major_object'

module GDAL
  # Wrapper for GDAL drivers (aka "formats"). Useful for opening and working
  # with GDAL datasets.
  class Driver
    extend T::Sig
    include MajorObject
    include GDAL::Logger

    GDAL_DOCS_URL = 'http://gdal.org'

    # @return [Integer]
    sig { returns(Integer) }
    def self.count
      FFI::GDAL::GDAL.GDALGetDriverCount
    end

    # @param name [String] Short name of the registered GDALDriver.
    # @return [GDAL::Driver]
    # @raise [GDAL::InvalidDriverName] If +name+ does not represent a valid
    #   driver name.
    sig { params(name: String).returns(GDAL::Driver) }
    def self.by_name(name)
      driver_ptr = FFI::GDAL::GDAL.GDALGetDriverByName(name)

      raise InvalidDriverName, "'#{name}' is not a valid driver name." if driver_ptr.null?

      new(driver_ptr)
    end

    # @param index [Integer] Index of the registered driver.  Must be less than
    #   GDAL::Driver.count.
    # @return [GDAL::Driver]
    # @raise [GDAL::InvalidDriverIndex] If driver at +index+ does not exist.
    sig { params(index: Integer).returns(GDAL::Driver) }
    def self.at_index(index)
      raise InvalidDriverIndex, "index must be between 0 and #{count - 1}." if index > count

      driver_ptr = FFI::GDAL::GDAL.GDALGetDriver(index)

      new(driver_ptr)
    end

    # @param file_path [String] File to get the driver for.
    # @return [GDAL::Driver] Returns nil if the file is unsupported.
    sig { params(file_path: String).returns(T.any(GDAL::Driver, NilClass)) }
    def self.identify_driver(file_path)
      driver_ptr = FFI::GDAL::GDAL.GDALIdentifyDriver(::File.expand_path(file_path), nil)
      return nil if driver_ptr.null?

      new(driver_ptr)
    end

    sig { returns(FFI::Pointer) }
    attr_reader :c_pointer

    # @param driver [GDAL::Driver, FFI::Pointer]
    sig { params(driver: T.any(GDAL::Driver, FFI::Pointer)).void }
    def initialize(driver)
      @c_pointer = GDAL._pointer(GDAL::Driver, driver, autorelease: false)
    end

    # @return [String]
    sig { returns(String) }
    def short_name
      # The returned string should not be freed and is owned by the driver.
      name, ptr = FFI::GDAL::GDAL.GDALGetDriverShortName(@c_pointer)
      ptr.autorelease = false

      name
    end

    # @return [String]
    sig { returns(String) }
    def long_name
      # The returned string should not be freed and is owned by the driver.
      name, ptr = FFI::GDAL::GDAL.GDALGetDriverLongName(@c_pointer)
      ptr.autorelease = false

      name
    end

    # @return [String]
    sig { returns(String) }
    def help_topic
      # The returned string should not be freed and is owned by the driver.
      url, ptr = FFI::GDAL::GDAL.GDALGetDriverHelpTopic(@c_pointer)
      ptr.autorelease = false

      "#{GDAL_DOCS_URL}/#{url}"
    end

    # Lists and describes the options that can be used when calling
    # GDAL::Dataset.create or GDAL::Dataset.create_copy.
    #
    # @return [Array]
    sig { returns(T::Array[String]) }
    def creation_option_list
      return [] unless @c_pointer

      # The returned string should not be freed and is owned by the driver.
      creation_option_list_xml, ptr = FFI::GDAL::GDAL.GDALGetDriverCreationOptionList(@c_pointer)
      ptr.autorelease = false
      root = MultiXml.parse(creation_option_list_xml)

      return [] if root.nil? || root.empty?

      list = root['CreationOptionList']
      return [] if list.nil? || list.empty?

      list['Option']
    end

    # @param options [Hash]
    # @return [Boolean]
    sig { params(options: T::Hash[T.any(String, Symbol), Object]).returns(T::Boolean) }
    def validate_creation_options(options)
      options_pointer = GDAL::Options.pointer(options)

      FFI::GDAL::GDAL.GDALValidateCreationOptions(@c_pointer, options_pointer)
    end

    # Copy all of the associated files of a dataset from one file to another.
    #
    # @param new_name [String]
    # @param old_name [String]
    # @return true on success, false on warning.
    # @raise [GDAL::Error] If failures.
    sig { params(old_name: String, new_name: String).returns(T::Boolean) }
    def copy_dataset_files(old_name, new_name)
      GDAL::CPLErrorHandler.manually_handle("Unable to copy dataset files: '#{old_name}' -> '#{new_name}'") do
        FFI::GDAL::GDAL.GDALCopyDatasetFiles(@c_pointer, new_name, old_name)
      end
    end

    # Create a new Dataset with this driver.  Legal arguments depend on the
    # driver and can't be retrieved programmatically.  NOTE: In order to write
    # out all data to the destination, you must call #close on the dataset!
    #
    # @param filename [String]
    # @param x_size [Integer] Width of created raster in pixels.
    # @param y_size [Integer] Height of created raster in pixels.
    # @param band_count [Integer]
    # @param data_type [FFI::GDAL::GDAL::DataType]
    # @return [GDAL::Dataset] If no block is given, returns the *open*
    #   (writable) dataset; you'll need to close it. If a block is given,
    #   returns the result of the block.
    sig do
      params(filename: String,
             x_size: Integer,
             y_size: Integer,
             band_count: Integer,
             data_type: Symbol,
             options: T::Hash[T.any(String, Symbol), Object])
        .returns(T.any(GDAL::Dataset, Object))
    end
    def create_dataset(filename, x_size, y_size, band_count: 1, data_type: :GDT_Byte, **options)
      options_pointer = GDAL::Options.pointer(options)

      dataset_pointer = FFI::GDAL::GDAL.GDALCreate(
        @c_pointer,
        filename,
        x_size,
        y_size,
        band_count,
        data_type,
        options_pointer
      )

      raise CreateFail if dataset_pointer.null?

      dataset = GDAL::Dataset.new(dataset_pointer, 'w')

      if block_given?
        result = yield(dataset)
        dataset.close

        result
      else
        dataset
      end
    end

    # Copies +source_dataset+ to +destination_path+. Will yield a writable
    # {{GDAL::Dataset}} of the destination dataset then close it if a block is
    # given.
    #
    # @param source_dataset [GDAL::Dataset, FFI::Pointer] The dataset to copy.
    # @param destination_path [String] The name for the new dataset file.
    # @param strict [Boolean] +false+ indicates the copy may adapt as needed for
    #   the output format.
    # @param options [Hash]
    # @param progress_function [Proc, FFI::GDAL::GDAL.GDALProgressFunc] For
    #   outputting copy progress.  Conforms to the
    #   FFI::GDAL::GDAL.GDALProgressFunc signature.
    # @param progress_data [Object]
    # @return [true]
    # @raise [GDAL::CreateFail] if it couldn't copy the dataset.
    # @yieldparam destination_dataset [GDAL::Dataset]
    sig do
      params(source_dataset: T.any(GDAL::Dataset, FFI::Pointer),
             destination_path: String,
             progress_function: T.any(
               NilClass,
               T.proc.params(completion_ratio: Float,
                             message: T.any(NilClass, String),
                             progress_arg: T.any(NilClass, Object))
               .returns(T::Boolean)
             ),
             progress_data: T.any(NilClass, Object),
             strict: T::Boolean,
             options: T::Hash[T.any(String, Symbol), Object])
        .returns(T::Boolean)
    end
    def copy_dataset(source_dataset, destination_path, progress_function = nil, progress_data = nil, strict: true,
      **options)
      source_dataset_ptr = make_dataset_pointer(source_dataset)
      raise GDAL::OpenFailure, "Source dataset couldn't be read" if source_dataset_ptr.null?

      options_ptr = GDAL::Options.pointer(options)

      destination_dataset_ptr = FFI::GDAL::GDAL.GDALCreateCopy(
        @c_pointer,
        destination_path,
        source_dataset_ptr,
        strict,
        options_ptr,
        progress_function,
        progress_data
      )

      raise CreateFail if destination_dataset_ptr.nil? || destination_dataset_ptr.null?

      if block_given?
        dataset = Dataset.new(destination_dataset_ptr, 'w')
        yield(dataset)
        dataset.close
      end

      true
    end

    # Delete the dataset represented by +file_name+.  Depending on the driver,
    # this could mean deleting associated files, database objects, etc.
    #
    # @param file_name [String]
    # @raise [GDAL::Error] If failures.
    sig { params(file_name: String).void }
    def delete_dataset(file_name)
      GDAL::CPLErrorHandler.manually_handle("Unable to delete dataset: #{file_name}") do
        FFI::GDAL::GDAL.GDALDeleteDataset(@c_pointer, file_name)
      end
    end

    # @param old_name [String]
    # @param new_name [String]
    # @raise [GDAL::Error] If failures.
    sig { params(old_name: String, new_name: String).void }
    def rename_dataset(old_name, new_name)
      GDAL::CPLErrorHandler.manually_handle("Unable to rename dataset: #{old_name}") do
        FFI::GDAL::GDAL.GDALRenameDataset(@c_pointer, new_name, old_name)
      end
    end

    private

    # @param [GDAL::Dataset, FFI::Pointer, String] dataset Can be another
    #   dataset, the pointer to another dataset, or the path to a dataset.
    # @return [FFI::Pointer]
    sig { params(dataset: T.any(String, GDAL::Dataset, FFI::Pointer)).returns(FFI::Pointer) }
    def make_dataset_pointer(dataset)
      if dataset.is_a? String
        GDAL::Dataset.open(dataset, 'r').c_pointer
      else
        GDAL._pointer(GDAL::Dataset, dataset, autorelease: false)
      end
    end
  end
end

require_relative 'dataset'
