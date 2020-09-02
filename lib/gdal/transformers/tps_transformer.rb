# typed: false
# frozen_string_literal: true

module GDAL
  module Transformers
    class TPSTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg::TPSTransform
      end

      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::GDAL::Alg.GDALDestroyTPSTransformer(pointer)
      end

      # @return [FFI::Pointer] C pointer to the C TPS transformer.
      attr_reader :c_pointer

      # @param gcp_list [Array<FFI::GDAL::GCP>]
      # @param reversed [Boolean]
      def initialize(gcp_list, reversed: false)
        gcp_list_ptr = FFI::MemoryPointer.new(:pointer, gcp_list.size)

        # TODO: fasterer: each_with_index is slower than loop
        gcp_list.each_with_index do |gcp, i|
          gcp_list_ptr[i].put_pointer(0, gcp.to_ptr)
        end

        pointer = FFI::GDAL::Alg.GDALCreateTPSTransformer(gcp_list.size, gcp_list_ptr, reversed)

        @c_pointer = FFI::AutoPointer.new(pointer, TPSTransformer.method(:release))
      end

      def destroy!
        TPSTransformer.release(@c_pointer)

        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end
    end
  end
end
