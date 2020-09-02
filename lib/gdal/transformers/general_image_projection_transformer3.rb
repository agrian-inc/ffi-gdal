# typed: true
# frozen_string_literal: true

require_relative 'base_general_image_projection_transformer'

module GDAL
  module Transformers
    class GeneralImageProjectionTransformer3 < BaseGeneralImageProjectionTransformer
      # @param source_wkt [String]
      # @param source_geo_transform [GDAL::GeoTransform, FFI::Pointer]
      # @param destination_wkt [String]
      # @param destination_geo_transform [GDAL::GeoTransform, FFI::Pointer]
      # @return [FFI::Pointer]
      def initialize(source_wkt, source_geo_transform, destination_wkt, destination_geo_transform)
        super()

        source_ptr = GDAL._pointer(GDAL::GeoTransform, source_geo_transform)
        destination_ptr = GDAL._pointer(GDAL::GeoTransform, destination_geo_transform)

        pointer = FFI::GDAL::Alg.GDALCreateGenImgProjTransformer3(
          source_wkt,
          source_ptr,
          destination_wkt,
          destination_ptr
        )

        raise if pointer.null?

        init_pointer(pointer)
      end
    end
  end
end
