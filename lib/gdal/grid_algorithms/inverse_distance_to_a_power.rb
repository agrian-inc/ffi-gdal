# typed: true
# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class InverseDistanceToAPower
      # @return [FFI::GDAL::GridInverseDistanceToAPowerOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GridInverseDistanceToAPowerOptions.new
      end

      # @return [Symbol]
      def c_identifier
        :GGA_InverseDistanceToAPower
      end
    end
  end
end
