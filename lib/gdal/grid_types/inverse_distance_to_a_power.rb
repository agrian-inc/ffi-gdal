require_relative '../../ffi/gdal/gdal_grid_inverse_distance_to_a_power_options'

module GDAL
  module GridTypes
    class InverseDistanceToAPower
      # @return [FFI::GDAL::GDALGridInverseDistanceToAPowerOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GDALGridInverseDistanceToAPowerOptions.new
      end

      def algorithm
        :GGA_InverseDistanceToAPower
      end
    end
  end
end
