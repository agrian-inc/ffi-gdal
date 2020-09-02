# typed: true
# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class NearestNeighbor
      # @return [FFI::GDAL::GridNearestNeighborOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GridNearestNeighborOptions.new
      end

      # @return [Symbol]
      def c_identifier
        :GGA_NearestNeighbor
      end
    end
  end
end
