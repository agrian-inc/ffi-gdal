# typed: true
# frozen_string_literal: true

module GDAL
  module Transformers
    class ReprojectionTransformer
      # @return [FFI::Pointer]
      def self.function
        FFI::GDAL::Alg::ReprojectionTransform
      end

      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::GDAL::Alg.GDALDestroyReprojectionTransformer(pointer)
      end

      # @return [FFI::Pointer] C pointer to the C reprojection transformer.
      attr_reader :c_pointer

      # @param source_wkt [String]
      # @param destination_wkt [String]
      def initialize(source_wkt, destination_wkt)
        pointer = FFI::GDAL::Alg.GDALCreateReprojectionTransformer(source_wkt, destination_wkt)

        @c_pointer = FFI::AutoPointer.new(pointer, ReprojectionTransformer.method(:release))
      end

      def destroy!
        ReprojectionTransformer.release(@c_pointer)

        @c_pointer = nil
      end

      # @return [FFI::Pointer]
      def function
        self.class.function
      end
    end
  end
end
