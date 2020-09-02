# typed: strict
# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    autoload :InverseDistanceToAPower,
             File.expand_path('grid_algorithms/inverse_distance_to_a_power', __dir__)
    autoload :MetricAverageDistance,
             File.expand_path('grid_algorithms/metric_average_distance', __dir__)
    autoload :MetricAverageDistancePts,
             File.expand_path('grid_algorithms/metric_average_distance_pts', __dir__)
    autoload :MetricCount,
             File.expand_path('grid_algorithms/metric_count', __dir__)
    autoload :MetricMaximum,
             File.expand_path('grid_algorithms/metric_maximum', __dir__)
    autoload :MetricMinimum,
             File.expand_path('grid_algorithms/metric_minimum', __dir__)
    autoload :MetricRange,
             File.expand_path('grid_algorithms/metric_range', __dir__)
    autoload :MovingAverage,
             File.expand_path('grid_algorithms/moving_average', __dir__)
    autoload :NearestNeighbor,
             File.expand_path('grid_algorithms/nearest_neighbor', __dir__)
  end
end
