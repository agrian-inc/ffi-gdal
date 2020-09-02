# typed: false
# frozen_string_literal: true

require_relative '../geometry_types/curve'

module OGR
  class LineString
    include OGR::Geometry
    include GeometryTypes::Curve

    def self.approximate_arc_angles(center_x, center_y, z, primary_radius, secondary_radius,
      rotation, start_angle, end_angle, max_angle_step_size_degrees = 0)
      geometry_ptr = FFI::GDAL::GDAL.OGR_G_ApproximateArcAngles(
        center_x,
        center_y,
        z,
        primary_radius,
        secondary_radius,
        rotation,
        start_angle,
        end_angle,
        max_angle_step_size_degrees
      )
      return nil if geometry_ptr.null?

      new(geometry_ptr)
    end

    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbLineString)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    # @param z [Float]
    def add_point(x, y, z = nil)
      if z
        FFI::OGR::API.OGR_G_AddPoint(@c_pointer, x, y, z)
      else
        FFI::OGR::API.OGR_G_AddPoint_2D(@c_pointer, x, y)
      end
    end

    # Wrapper for {#add_point} to allow passing in an {OGR::Point} instead of
    # individual coordinates.
    #
    # @param point [OGR::Point]
    def add_geometry(point)
      if point.is_3d?
        add_point(point.x, point.y, point.z)
      else
        add_point(point.x, point.y)
      end
    end
  end
end
