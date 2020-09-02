# typed: true
# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class DataMetricsBase
      # @return [FFI::GDAL::GridDataMetricsOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GridDataMetricsOptions.new
      end
    end
  end
end
