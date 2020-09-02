# typed: true
# frozen_string_literal: true

module GDAL
  module Transformers
    class RPCTransformer
      # @return [FFI::Pointer]
      def self.function
        FFI::GDAL::Alg::RPCTransform
      end

      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::GDAL::Alg.GDALDestroyRPCTransformer(pointer)
      end

      # @return [FFI::Pointer] C pointer to the C RPC transformer.
      attr_reader :c_pointer

      # @param rpc_info [GDAL::RPCInfo]
      # @param reversed [Boolean]
      # @param pixel_error_threshold [Float]
      # @param options [Hash]
      # @option options [Number] rpc_height A fixed hight offset to be applied to
      #   all points passed in.
      # @option options [Number] rpc_height_scale A factor used to multiply
      #   heights above ground.  Useful when elevation offsets of the DEM are not
      #   expressed in meters.
      # @option options [Number] rpc_dem Name of a GDAL dataset used to extract
      #   elevation offsets from.  This should be used in replacement of
      #   +rpc_height+.
      # @option options [Number] rpc_deminterpolation +near+, +bilinear+, or
      #   +cubic+.
      # @option options [Number] rpc_dem_missing_value Value of DEM height that
      #   must be unsed in case the DEM has a nodata value at the sampling point,
      #   or if its extent doesn't cover the requested coordinate.
      def initialize(rpc_info, pixel_error_threshold, reversed: false, **options)
        options_ptr = GDAL::Options.pointer(options)

        pointer = FFI::GDAL::Alg.GDALCreateRPCTransformer(
          rpc_info,
          reversed,
          pixel_error_threshold,
          options_ptr
        )

        @c_pointer = FFI::AutoPointer.new(pointer, RPCTransformer.method(:release))
      end

      def destroy!
        return unless @c_pointer

        FFI::GDAL::Alg.GDALDestroyRPCTransformer(@c_pointer)
        @c_pointer = nil
      end

      # @return [FFI::Pointer]
      def function
        self.class.function
      end
    end
  end
end
