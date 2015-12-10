module GDAL
  module Transformers
    class GeolocationTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg::GeoLocTransform
      end

      # @return [FFI::Pointer] C pointer to the C geolocation transformer.
      attr_reader :c_pointer

      # @param base_dataset [GDAL::Dataset]
      # @param geolocation_info [Array<String>]
      # @param reversed [Boolean]
      def intialize(base_dataset, geolocation_info, reversed = false)
        base_dataset_ptr = GDAL._pointer(GDAL::Dataset, base_dataset)
        geolocation_info_ptr = GDAL._string_array_to_pointer(geolocation_info)

        @c_pointer = FFI::GDAL::Alg.CreateGeoLocTransformer(
          base_dataset_ptr,
          geolocation_info_ptr,
          reversed)
      end

      def destroy!
        return unless @c_pointer

        FFI::GDAL::Alg.GDALDestroyGeoLocTransformer(@c_pointer)
        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end
    end
  end
end
