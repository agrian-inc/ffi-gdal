# typed: false
# frozen_string_literal: true

require_relative 'point'

module OGR
  # NOTE: {{#type}} will return :wkbPoint (read: 2D instead of 2.5D) until a Z
  # value is set.
  class Point25D < Point
    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbPoint25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end

    # @return [Float]
    def z
      return if empty?

      FFI::OGR::API.OGR_G_GetZ(@c_pointer, 0)
    end

    # @return [Array<Float, Float, Float>] [x, y, z].
    def point
      return [] if empty?

      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)
      FFI::OGR::API.OGR_G_GetPoint(@c_pointer, 0, x_ptr, y_ptr, z_ptr)

      [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
    end

    # @param x [Number]
    # @param y [Number]
    # @param z [Number]
    def set_point(x, y, z)
      FFI::OGR::API.OGR_G_SetPoint(@c_pointer, 0, x, y, z)
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    # @param z [Float]
    def add_point(x, y, z)
      FFI::OGR::API.OGR_G_AddPoint(@c_pointer, x, y, z)
    end
  end
end
