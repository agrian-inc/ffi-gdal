# typed: false
# frozen_string_literal: true

require_relative '../gdal'

module GDAL
  class RasterAttributeTable
    # Create an object from a ColorTable.
    #
    # @param color_table [GDAL::ColorTable, FFI::Pointer]
    # @return [GDAL::RasterAttributeTable]
    # @raise [GDAL::Error]
    def self.from_color_table(color_table)
      color_table_ptr = GDAL._pointer(GDAL::ColorTable, color_table, autorelease: false)
      rat_ptr = FFI::GDAL::GDAL.GDALCreateRasterAttributeTable

      GDAL::CPLErrorHandler.manually_handle('Unable to initialize from ColorTable') do
        FFI::GDAL::GDAL.GDALRATInitializeFromColorTable(rat_ptr, color_table_ptr)
      end

      new(rat_ptr)
    end

    # @param raster_attribute_table [GDAL::RasterAttributeTable]
    # @return [FFI::AutoPointer]
    def self.new_pointer(raster_attribute_table)
      ptr = GDAL._pointer(GDAL::Dataset, raster_attribute_table, autorelease: false)

      FFI::AutoPointer.new(ptr, RasterAttributeTable.method(:release))
    end

    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      return unless pointer && !pointer.null?

      FFI::GDAL::GDAL.GDALDestroyRasterAttributeTable(pointer)
    end

    # @return [FFI::Pointer] The C pointer that represents the C RAT.
    attr_reader :c_pointer

    # @param pointer [FFI::Pointer]
    def initialize(pointer = nil)
      @c_pointer = pointer || FFI::GDAL::GDAL.GDALCreateRasterAttributeTable
    end

    def destroy!
      RasterAttributeTable.release(@c_pointer)

      @c_pointer = nil
    end

    # Clone using the C API.
    #
    # @return [GDAL::RasterAttributeTable]
    def clone
      rat_ptr = FFI::GDAL::GDAL.GDALRATClone(@c_pointer)
      return nil if rat_ptr.nil? || rat_ptr.null?

      self.class.new(rat_ptr)
    end

    # +true+ if the changes made to this RAT have been written to the associated
    # dataset.
    #
    # @return [Boolean]
    def changes_written_to_file?
      FFI::GDAL::GDAL.GDALRATChangesAreWrittenToFile(@c_pointer)
    end

    # @return [Integer]
    def column_count
      FFI::GDAL::GDAL.GDALRATGetColumnCount(@c_pointer)
    end

    # @param index [Integer] The column number.
    # @return [String]
    def column_name(index)
      name, ptr = FFI::GDAL::GDAL.GDALRATGetNameOfCol(@c_pointer, index)
      ptr.autorelease = false

      name
    end
    alias name_of_col column_name

    # @param index [Integer] The column number.
    # @return [GDALRATFieldUsage]
    def column_usage(index)
      FFI::GDAL::GDAL.GDALRATGetUsageOfCol(@c_pointer, index)
    end
    alias usage_of_col column_usage

    # @param index [Integer] The column number.
    # @return [GDALRATFieldType]
    def column_type(index)
      FFI::GDAL::GDAL.GDALRATGetTypeOfCol(@c_pointer, index)
    end
    alias type_of_col column_type

    # @param field_usage [GDALRATFieldUsage]
    # @return [Integer] The column number or nil.
    def column_of_usage(field_usage)
      column_number = FFI::GDAL::GDAL.GDALRATGetColOfUsage(@c_pointer, field_usage)
      return if column_number.negative?

      column_number
    end

    # @param name [String]
    # @param type [FFI::GDAL::GDALRATFieldType]
    # @param usage [FFI::GDAL::GDALRATFieldUsage]
    # @raise [GDAL::Error]
    def create_column(name, type, usage)
      GDAL::CPLErrorHandler.manually_handle('Unable to create column') do
        FFI::GDAL::GDAL.GDALRATCreateColumn(@c_pointer, name, type, usage)
      end
    end

    # @return [Integer] The number of rows.
    def row_count
      FFI::GDAL::GDAL.GDALRATGetRowCount(@c_pointer)
    end

    # @return [Integer] The number of rows.
    def row_count=(count)
      FFI::GDAL::GDAL.GDALRATSetRowCount(@c_pointer, count)
    end

    # Get the row for a pixel value.
    #
    # @param pixel_value [Float]
    # @return [Integer] Index of the row or nil.
    def row_of_value(pixel_value)
      row_index = FFI::GDAL::GDAL.GDALRATGetRowOfValue(@c_pointer, pixel_value)
      return if row_index.negative?

      row_index
    end

    # @param row [Integer]
    # @param field [Integer]
    # @return [String]
    def value_as_string(row, field)
      value_string, ptr = FFI::GDAL::GDAL.GDALRATGetValueAsString(@c_pointer, row, field)
      ptr.autorelease = false

      value_string
    end

    # @param row [Integer]
    # @param field [Integer]
    # @return [Integer]
    def value_as_integer(row, field)
      FFI::GDAL::GDAL.GDALRATGetValueAsInt(@c_pointer, row, field)
    end
    alias value_as_int value_as_integer

    # @param row [Integer]
    # @param field [Integer]
    # @return [Float]
    def value_as_double(row, field)
      FFI::GDAL::GDAL.GDALRATGetValueAsDouble(@c_pointer, row, field)
    end
    alias value_as_float value_as_double

    # @param row [Integer]
    # @param field [Integer]
    # @param value [String]
    def set_value_as_string(row, field, value)
      FFI::GDAL::GDAL.GDALRATSetValueAsString(@c_pointer, row, field, value)
    end

    # @param row [Integer]
    # @param field [Integer]
    # @param value [Float]
    def set_value_as_double(row, field, value)
      FFI::GDAL::GDAL.GDALRATSetValueAsDouble(@c_pointer, row, field, value)
    end
    alias set_value_as_float set_value_as_double

    # @param row [Integer]
    # @param field [Integer]
    # @param value [Integer]
    def set_value_as_integer(row, field, value)
      FFI::GDAL::GDAL.GDALRATSetValueAsInt(@c_pointer, row, field, value)
    end
    alias set_value_as_int set_value_as_integer

    # @return [Hash{row_0_minimum => Float, bin_size => Float}]
    def linear_binning
      row_0_min_ptr = FFI::MemoryPointer.new(:double)
      bin_size_ptr = FFI::MemoryPointer.new(:double)
      result = FFI::GDAL::GDAL.GDALRATGetLinearBinning(@c_pointer, row_0_min_ptr, bin_size_ptr)
      return unless result

      {
        row_0_minimum: row_0_min_ptr.read_double,
        bin_size: bin_size_ptr.read_double
      }
    end

    # @param row_0_minimum [Float]
    # @param bin_size [Float]
    # @raise [GDAL::Error]
    def set_linear_binning(row_0_minimum, bin_size)
      GDAL::CPLErrorHandler.manually_handle('Unable to set linear binning') do
        FFI::GDAL::GDAL.GDALRATSetLinearBinning(@c_pointer, row_0_minimum, bin_size)
      end
    end

    # @param entry_count [Integer] The number of entries to produce.  The default
    #   will try to auto-determine the number.
    # @return [GDAL::ColorTable, nil]
    def to_color_table(entry_count = -1)
      color_table_pointer = FFI::GDAL::GDAL.GDALRATTranslateToColorTable(@c_pointer, entry_count)
      return if color_table_pointer.nil? || color_table_pointer.null?

      GDAL::ColorTable.new(color_table_pointer)
    end

    # @param file_path [String] Without giving a +file_path+, dumps to STDOUT.
    def dump_readable(file_path = nil)
      file_ptr = file_path ? FFI::CPL::Conv.CPLOpenShared(file_path, 'w', false) : nil
      FFI::GDAL::GDAL.GDALRATDumpReadable(@c_pointer, file_ptr)
      FFI::CPL::Conv.CPLCloseShared(file_ptr) if file_ptr
    end
  end
end
