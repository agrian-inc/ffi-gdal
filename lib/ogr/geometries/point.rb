# typed: false
# frozen_string_literal: true

module OGR
  class Point
    include OGR::Geometry

    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbPoint)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end

    # @return [Float]
    def x
      return nil if empty?

      FFI::OGR::API.OGR_G_GetX(@c_pointer, 0)
    end

    # @return [Float]
    def y
      return nil if empty?

      FFI::OGR::API.OGR_G_GetY(@c_pointer, 0)
    end

    # @return [<Array<Float, Float>] [x, y].
    def point
      return [] if empty?

      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)
      FFI::OGR::API.OGR_G_GetPoint(@c_pointer, 0, x_ptr, y_ptr, z_ptr)

      [x_ptr.read_double, y_ptr.read_double]
    end
    alias point_value point

    # @param x [Number]
    # @param y [Number]
    def set_point(x, y)
      FFI::OGR::API.OGR_G_SetPoint_2D(@c_pointer, 0, x, y)
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    def add_point(x, y)
      FFI::OGR::API.OGR_G_AddPoint_2D(@c_pointer, x, y)
    end
  end
end
