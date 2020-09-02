# typed: false
# frozen_string_literal: true

module OGR
  module GeometryTypes
    module Surface
      # Computes area for a LinearRing, Polygon, or MultiPolygon.  The area of
      # the feature is in square units of the spatial reference system in use.
      #
      # @return [Float] 0.0 for unsupported geometry types.
      def area
        FFI::OGR::API.OGR_G_Area(@c_pointer)
      end

      # Returns the units used by the associated OGR::SpatialReference.
      #
      # @return [Hash]
      def area_units
        spatial_reference ? spatial_reference.linear_units : nil
      end
    end
  end
end
