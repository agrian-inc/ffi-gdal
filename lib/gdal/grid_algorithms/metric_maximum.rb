# typed: true
# frozen_string_literal: true

require_relative 'data_metrics_base'

module GDAL
  module GridAlgorithms
    class MetricMaximum < DataMetricsBase
      # @return [Symbol]
      def c_identifier
        :GGA_MetricMaximum
      end
    end
  end
end
