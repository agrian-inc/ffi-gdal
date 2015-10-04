require_relative 'point'

module OGR
  class Point25D < Point
    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbPoint25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end

    # @return [Float]
    def z
      return nil if empty?

      FFI::OGR::API.OGR_G_GetZ(@c_pointer, 0)
    end

    # @return [Array<Float, Float, Float>] [x, y] if 2d or [x, y, z] if 3d.
    def point_values
      return [] if empty?

      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)
      FFI::OGR::API.OGR_G_GetPoint(@c_pointer, 0, x_ptr, y_ptr, z_ptr)

      [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
    end
  end
end
