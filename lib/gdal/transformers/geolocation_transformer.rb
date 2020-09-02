# typed: false
# frozen_string_literal: true

module GDAL
  module Transformers
    class GeolocationTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg::GeoLocTransform
      end

      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::GDAL::Alg.GDALDestroyGeoLocTransformer(pointer)
      end

      # @return [FFI::Pointer] C pointer to the C geolocation transformer.
      attr_reader :c_pointer

      # @param base_dataset [GDAL::Dataset]
      # @param geolocation_info [Array<String>]
      # @param reversed [Boolean]
      def intialize(base_dataset, geolocation_info, reversed: false)
        base_dataset_ptr = GDAL._pointer(GDAL::Dataset, base_dataset)
        geolocation_info_ptr = GDAL._string_array_to_pointer(geolocation_info)

        pointer = FFI::GDAL::Alg.CreateGeoLocTransformer(
          base_dataset_ptr,
          geolocation_info_ptr,
          reversed
        )

        @c_pointer = FFI::AutoPointer.new(pointer, GeolocationTransformer.method(:release))
      end

      def destroy!
        GeolocationTransformer.release(@c_pointer)

        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end
    end
  end
end
