# typed: true
# frozen_string_literal: true

module GDAL
  # Info about GDAL data types (GDT symbols).
  class DataType
    # The size in bits.
    #
    # @param gdal_data_type [FFI::GDAL::GDAL::DataType]
    # @return [Integer]
    def self.size(gdal_data_type)
      FFI::GDAL::GDAL.GDALGetDataTypeSize(gdal_data_type)
    end

    # @param gdal_data_type [FFI::GDAL::GDAL::DataType]
    # @return [Integer]
    def self.complex?(gdal_data_type)
      FFI::GDAL::GDAL.GDALDataTypeIsComplex(gdal_data_type)
    end

    # @param gdal_data_type [FFI::GDAL::GDAL::DataType]
    # @return [String]
    def self.name(gdal_data_type)
      # The returned strings are static strings and should not be modified or
      # freed by the application.
      name, ptr = FFI::GDAL::GDAL.GDALGetDataTypeName(gdal_data_type)
      ptr.autorelease = false

      name
    end

    # The data type's symbolic name.
    #
    # @param name [String]
    # @return [FFI::GDAL::GDAL::DataType]
    def self.by_name(name)
      FFI::GDAL::GDAL.GDALGetDataTypeByName(name.to_s)
    end

    # Return the smallest data type that can fully express both input data types.
    #
    # @param gdal_data_type1 [FFI::GDAL::GDAL::DataType]
    # @param gdal_data_type2 [FFI::GDAL::GDAL::DataType]
    # @return [FFI::GDAL::GDAL::DataType]
    def self.union(gdal_data_type1, gdal_data_type2)
      FFI::GDAL::GDAL.GDALDataTypeUnion(gdal_data_type1, gdal_data_type2)
    end
  end
end
