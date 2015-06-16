require_relative '../../ffi/gdal/grid_data_metrics_options'

module GDAL
  module GridTypes
    class DataMetricsBase
      # @return [FFI::GDAL::GridDataMetricsOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GridDataMetricsOptions.new
      end
    end
  end
end