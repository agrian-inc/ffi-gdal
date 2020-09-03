# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module GDAL
  # Info about GDAL data types (GDT symbols).
  class DataType
    extend T::Sig

    # The size in bits.
    #
    # @param gdal_data_type [FFI::Enum] A FFI::GDAL::GDAL::DataType.
    # @return [Integer]
    sig { params(gdal_data_type: FFI::Enum).returns(Integer) }
    def self.size(gdal_data_type)
      FFI::GDAL::GDAL.GDALGetDataTypeSize(gdal_data_type)
    end

    # @param gdal_data_type [FFI::Enum] A FFI::GDAL::GDAL::DataType.
    # @return [Boolean]
    sig { params(gdal_data_type: FFI::Enum).returns(T::Boolean) }
    def self.complex?(gdal_data_type)
      FFI::GDAL::GDAL.GDALDataTypeIsComplex(gdal_data_type)
    end

    # @param gdal_data_type [FFI::Enum] A FFI::GDAL::GDAL::DataType.
    # @return [String]
    sig { params(gdal_data_type: FFI::Enum).returns(String) }
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
    # @return [FFI::Enum] A FFI::GDAL::GDAL::DataType.
    sig { params(name: String).returns(FFI::Enum) }
    def self.by_name(name)
      FFI::GDAL::GDAL.GDALGetDataTypeByName(name.to_s)
    end

    # Return the smallest data type that can fully express both input data types.
    #
    # @param gdal_data_type1 [FFI::Enum] A FFI::GDAL::GDAL::DataType.
    # @param gdal_data_type2 [FFI::Enum] A FFI::GDAL::GDAL::DataType.
    # @return [FFI::Enum] A FFI::GDAL::GDAL::DataType.
    sig { params(gdal_data_type1: FFI::Enum, gdal_data_type2: FFI::Enum).returns(FFI::Enum) }
    def self.union(gdal_data_type1, gdal_data_type2)
      FFI::GDAL::GDAL.GDALDataTypeUnion(gdal_data_type1, gdal_data_type2)
    end
  end
end
