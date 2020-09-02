# typed: false
# frozen_string_literal: true

module OGR
  module GeometryTypes
    module Curve
      # @return [Float]
      def x(point_number)
        FFI::OGR::API.OGR_G_GetX(@c_pointer, point_number)
      end

      # @return [Float]
      def y(point_number)
        FFI::OGR::API.OGR_G_GetY(@c_pointer, point_number)
      end

      # @return [Float]
      def z(point_number)
        FFI::OGR::API.OGR_G_GetZ(@c_pointer, point_number)
      end

      # @param number [Integer] Index of the point to get.
      # @return [Array<Float, Float, Float>] [x, y] if 2d or [x, y, z] if 3d.
      def point(number)
        x_ptr = FFI::MemoryPointer.new(:double)
        y_ptr = FFI::MemoryPointer.new(:double)
        z_ptr = FFI::MemoryPointer.new(:double)

        FFI::OGR::API.OGR_G_GetPoint(@c_pointer, number, x_ptr, y_ptr, z_ptr)

        if coordinate_dimension == 2
          [x_ptr.read_double, y_ptr.read_double]
        else
          [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
        end
      end
      alias get_point point

      # Adds a point to a LineString or Point geometry.
      #
      # @param x [Float]
      # @param y [Float]
      # @param z [Float]
      def add_point(x, y, z = 0)
        if coordinate_dimension == 3
          FFI::OGR::API.OGR_G_AddPoint(@c_pointer, x, y, z)
        else
          FFI::OGR::API.OGR_G_AddPoint_2D(@c_pointer, x, y)
        end
      end

      # @param index [Integer] The index of the vertex to assign.
      # @param x [Number]
      # @param y [Number]
      # @param z [Number]
      def set_point(index, x, y, z = nil)
        if is_3d?
          FFI::OGR::API.OGR_G_SetPoint(@c_pointer, index, x, y, z)
        else
          FFI::OGR::API.OGR_G_SetPoint_2D(@c_pointer, index, x, y)
        end
      end

      # @return [Array<Array<Float>>] An array of (x, y) or (x, y, z) points.
      def points
        x_stride = FFI::Type::DOUBLE.size
        y_stride = FFI::Type::DOUBLE.size
        z_stride = coordinate_dimension == 3 ? FFI::Type::DOUBLE.size : 0

        buffer_size = point_count
        x_buffer = FFI::MemoryPointer.new(:buffer_out, buffer_size)
        y_buffer = FFI::MemoryPointer.new(:buffer_out, buffer_size)
        z_buffer = FFI::MemoryPointer.new(:buffer_out, buffer_size) if coordinate_dimension == 3

        num_points = FFI::OGR::API.OGR_G_GetPoints(@c_pointer,
                                                   x_buffer, x_stride, y_buffer,
                                                   y_stride, z_buffer, z_stride)

        log 'Got different number of points than point_count in #point_values' unless num_points == point_count

        x_array = x_buffer.read_array_of_double(buffer_size)
        y_array = y_buffer.read_array_of_double(buffer_size)

        if z_buffer
          z_array = z_buffer.read_array_of_double(buffer_size)

          [x_array, y_array, z_array].transpose
        else
          [x_array, y_array].transpose
        end
      end
      alias get_points points
      alias point_values points

      # @param new_count [Integer]
      def point_count=(new_count)
        FFI::OGR::API.OGR_G_SetPointCount(@c_pointer, new_count)
      end

      # Computes the length for this geometry.  Computes area for Curve or
      # MultiCurve objects.
      #
      # @return [Float] 0.0 for unsupported geometry types.
      def length
        FFI::OGR::API.OGR_G_Length(@c_pointer)
      end
    end
  end
end
