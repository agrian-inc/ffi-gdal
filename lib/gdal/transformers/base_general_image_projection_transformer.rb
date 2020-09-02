# typed: true
# frozen_string_literal: true

module GDAL
  module Transformers
    class BaseGeneralImageProjectionTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg::GenImgProjTransform
      end

      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::GDAL::Alg.GDALDestroyGenImgProjTransformer(pointer)
      end

      # @return [FFI::Pointer]
      attr_reader :c_pointer

      def destroy!
        BaseGeneralImageProjectionTransformer.release(@c_pointer)

        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end

      # Normally the destination geotransform is extracted from the destination
      # file by the transformer and stored in internal private info. However,
      # sometimes it is inconvenient to have an output file handle with
      # appropriate geotransform information when creating the transformation.
      # For these cases, this function can be used to apply the destination
      # geotransform.
      #
      # @param [FFI::Pointer, GDAL::GeoTransform] geo_transform
      def destination_geo_transform=(geo_transform)
        geo_transform_ptr = GDAL._pointer(GDAL::GeoTransform, geo_transform)

        FFI::GDAL::Alg.GDALSetGenImgProjTransformerDstGeoTransform(
          @c_pointer, geo_transform_ptr
        )
      end

      private

      def init_pointer(pointer)
        @c_pointer = FFI::AutoPointer.new(pointer, BaseGeneralImageProjectionTransformer.method(:release))
      end
    end
  end
end
