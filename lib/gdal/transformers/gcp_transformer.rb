module GDAL
  module Transformers
    class GCPTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg::GCPTransform
      end

      # @return [FFI::Pointer] C pointer to the GCP transformer.
      attr_reader :c_pointer

      # @param gcp_list [Array<FFI::GDAL::GCP>]
      # @param requested_polynomial_order [Fixnum] 1, 2, or 3.
      # @param reversed [Boolean]
      def initialize(gcp_list, requested_polynomial_order, reversed = false,
        tolerance: nil, minimum_gcps: nil)
        gcp_list_ptr = FFI::MemoryPointer.new(:pointer, gcp_list.size)

        gcp_list.each_with_index do |gcp, i|
          gcp_list_ptr[i].put_pointer(0, gcp.to_ptr)
        end

        @c_pointer = if tolerance || minimum_gcps
                       FFI::GDAL::Alg.GDALCreateGCPRefineTransformer(
                         gcp_list.size,
                         gcp_list_ptr,
                         requested_polynomial_order,
                         reversed)
                     else
                       FFI::GDAL::Alg.GDALCreateGCPTransformer(
                         gcp_list.size,
                         gcp_list_ptr,
                         requested_polynomial_order,
                         reversed)
                     end
      end

      def destroy!
        return unless @c_pointer

        FFI::GDAL::Alg.GDALDestroyGCPTransformer(@c_pointer)
        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end
    end
  end
end
