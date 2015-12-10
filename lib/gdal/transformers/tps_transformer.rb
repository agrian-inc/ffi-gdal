module GDAL
  module Transformers
    class TPSTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg::TPSTransform
      end

      # @return [FFI::Pointer] C pointer to the C TPS transformer.
      attr_reader :c_pointer

      # @param gcp_list [Array<FFI::GDAL::GCP>]
      # @param reversed [Boolean]
      def initialize(gcp_list, reversed = false)
        gcp_list_ptr = FFI::MemoryPointer.new(:pointer, gcp_list.size)

        gcp_list.each_with_index do |gcp, i|
          gcp_list_ptr[i].put_pointer(0, gcp.to_ptr)
        end

        @c_pointer = FFI::GDAL::Alg.GDALCreateTPSTransformer(gcp_list.size, gcp_list_ptr, reversed)
      end

      def destroy!
        return unless @c_pointer

        FFI::GDAL::Alg.GDALDestroyTPSTransformer(@c_pointer)
        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end
    end
  end
end
