# typed: false
# frozen_string_literal: true

module GDAL
  module Transformers
    class GCPTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg::GCPTransform
      end

      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::GDAL::Alg.GDALDestroyGCPTransformer(pointer)
      end

      # @return [FFI::Pointer] C pointer to the GCP transformer.
      attr_reader :c_pointer

      # @param gcp_list [Array<FFI::GDAL::GCP>]
      # @param requested_polynomial_order [Integer] 1, 2, or 3.
      # @param reversed [Boolean]
      def initialize(gcp_list, requested_polynomial_order, reversed: false, tolerance: nil, minimum_gcps: nil)
        gcp_list_ptr = FFI::MemoryPointer.new(:pointer, gcp_list.size)

        # TODO: fasterer: each_with_index is slower than loop
        gcp_list.each_with_index do |gcp, i|
          gcp_list_ptr[i].put_pointer(0, gcp.to_ptr)
        end

        pointer = if tolerance || minimum_gcps
                    FFI::GDAL::Alg.GDALCreateGCPRefineTransformer(
                      gcp_list.size,
                      gcp_list_ptr,
                      requested_polynomial_order,
                      reversed
                    )
                  else
                    FFI::GDAL::Alg.GDALCreateGCPTransformer(
                      gcp_list.size,
                      gcp_list_ptr,
                      requested_polynomial_order,
                      reversed
                    )
                  end

        @c_pointer = FFI::AutoPointer.new(pointer, GCPTransformer.method(:release))
      end

      def destroy!
        GCPTransformer.release(@c_pointer)

        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end
    end
  end
end
