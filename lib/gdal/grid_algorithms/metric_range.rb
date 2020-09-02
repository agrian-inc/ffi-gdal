# typed: true
# frozen_string_literal: true

require_relative 'data_metrics_base'

module GDAL
  module GridAlgorithms
    class MetricRange < DataMetricsBase
      # @return [Symbol]
      def c_identifier
        :GGA_MetricRange
      end
    end
  end
end
