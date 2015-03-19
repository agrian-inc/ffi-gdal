require_relative '../../ffi/gdal/alg'

module GDAL
  module Transformers
    class ReprojectionTransformer
      # @return [FFI::Pointer]
      def self.function
        FFI::GDAL::Alg::ReprojectionTransform
      end

      attr_reader :c_pointer

      # @param source_wkt [String]
      # @param destination_wkt [String]
      def initialize(source_wkt, destination_wkt)
        @c_pointer = FFI::GDAL::Alg.GDALCreateReprojectionTransformer(source_wkt, destination_wkt)

        ObjectSpace.define_finalizer(transformer_ptr) do
          destroy_reprojection_transformer(transformer_ptr)
        end

        transformer_ptr
      end

      def destroy!
        return unless @c_pointer

        FFI::GDAL::Alg.GDALDestroyReprojectionTransformer(@c_pointer)
        @c_pointer = nil
      end

      # @return [FFI::Pointer]
      def function
        self.class.function
      end
    end
  end
end
