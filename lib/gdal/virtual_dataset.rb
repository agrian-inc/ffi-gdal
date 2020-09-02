# typed: true
# frozen_string_literal: true

require_relative '../gdal'
require_relative 'major_object'

module GDAL
  class VirtualDataset
    include MajorObject

    attr_reader :c_pointer

    def initialize(x_size, y_size)
      FFI::GDAL::VRT.GDALRegister_VRT
      @c_pointer = FFI::GDAL::VRT.VRTCreate(x_size, y_size)
    end

    def flush_cache
      FFI::GDAL::VRT.VRTFlushCache(@c_pointer)
    end

    # TODO: Build the xml string
    def to_xml(path = '')
      xml_node = FFI::GDAL::VRT.VRTSerializeToXML(@c_pointer, path)

      FFI::CPL::MiniXML.CPLSerializeXMLTree(xml_node)
    end

    # @param data_type [FFI::GDAL::GDAL::DataType]
    # @param options [Hash]
    # @return [Boolean]
    def add_band(data_type, **options)
      options_ptr = GDAL::Options.pointer(options)

      FFI::GDAL::VRT.VRTAddBand(@c_pointer, data_type, options_ptr)
    end

    # @param vrt_band [FFI::Pointer]
    # @param new_source [FFI::Pointer]
    # @return [Boolean] [description]
    def add_source(vrt_band, new_source)
      FFI::GDAL::VRT.VRTAddSource(vrt_band, new_source)
    end

    # rubocop:disable Metrics/ParameterLists
    # @return [Boolean]
    def add_simple_source(vrt_band, source_band, no_data_value,
      src_x_offset: 0, src_y_offset: 0, src_x_size: nil, src_y_size: nil,
      dst_x_offset: 0, dst_y_offset: 0, dst_x_size: nil, dst_y_size: nil,
      resampling: '')
      FFI::GDAL::VRT.VRTAddSimpleSource(
        vrt_band,
        source_band,      # hSrcBand
        src_x_offset,     # hSrcBand
        src_y_offset,     # hSrcBand
        src_x_size,       # hSrcBand
        src_y_size,       # hSrcBand
        dst_x_offset,     # hSrcBand
        dst_y_offset,     # hSrcBand
        dst_x_size,       # hSrcBand
        dst_y_size,       # hSrcBand
        resampling,       # pszResampling,
        no_data_value     # dfNoDataValue
      )
    end

    # @return [Boolean]
    def add_complex_source(vrt_band, source_band, no_data_value,
      src_x_offset: 0, src_y_offset: 0, src_x_size: nil, src_y_size: nil,
      dst_x_offset: 0, dst_y_offset: 0, dst_x_size: nil, dst_y_size: nil,
      scale_offset: 0.0, scale_ratio: 0.0)
      FFI::GDAL::VRT.VRTAddComplexSource(
        vrt_band,
        source_band,      # hSrcBand
        src_x_offset,     # hSrcBand
        src_y_offset,     # hSrcBand
        src_x_size,       # hSrcBand
        src_y_size,       # hSrcBand
        dst_x_offset,     # hSrcBand
        dst_y_offset,     # hSrcBand
        dst_x_size,       # hSrcBand
        dst_y_size,       # hSrcBand
        scale_offset,     # dfScaleOff
        scale_ratio,      # dfScaleRatio
        no_data_value     # dfNoDataValue
      )
    end
    # rubocop:enable Metrics/ParameterLists

    # @param vrt_band [FFI::Pointer]
    # @param read_function [Proc]
    # @param data [FFI::Pointer]
    # @param no_data_value [Float]
    # @return [Boolean]
    def add_func_source(vrt_band, read_function, data, no_data_value)
      FFI::GDAL::VRT.VRTAddFuncSource(vrt_band, read_function, data, no_data_value)
    end
  end
end
