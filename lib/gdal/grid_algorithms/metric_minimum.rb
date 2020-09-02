# typed: true
# frozen_string_literal: true

require_relative 'data_metrics_base'

module GDAL
  module GridAlgorithms
    class MetricMinimum < DataMetricsBase
      # @return [Symbol]
      def c_identifier
        :GGA_MetricMinimum
      end
    end
  end
end
