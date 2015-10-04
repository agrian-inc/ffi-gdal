require_relative 'point_extensions'

module OGR
  class Point
    include OGR::Geometry
    include PointExtensions

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

    # @return [Float]
    def z
      return nil if empty?

      FFI::OGR::API.OGR_G_GetZ(@c_pointer, 0)
    end

    # @return [Array<Float, Float, Float>] [x, y] if 2d or [x, y, z] if 3d.
    def point
      return [] if empty?

      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)

      FFI::OGR::API.OGR_G_GetPoint(@c_pointer, 0, x_ptr, y_ptr, z_ptr)

      if coordinate_dimension == 2
        [x_ptr.read_double, y_ptr.read_double]
      else
        [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
      end
    end

    def set_point(x, y, z = 0)
      FFI::OGR::API.OGR_G_SetPoint(@c_pointer, 0, x, y, z)
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    # @param z [Float]
    def add_point(x, y, z = 0)
      FFI::OGR::API.OGR_G_AddPoint(@c_pointer, x, y, z)
    end
  end
end
