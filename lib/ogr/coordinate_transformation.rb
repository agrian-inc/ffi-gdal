# typed: false
# frozen_string_literal: true

require 'narray'
require_relative '../ogr'
require_relative '../gdal'

module OGR
  class CoordinateTransformation
    # @param proj4_source [String]
    # @return [String]
    def self.proj4_normalize(proj4_source)
      if GDAL._supported?(:OCTProj4Normalize)
        FFI::GDAL::GDAL.OCTProj4Normalize(proj4_source)
      else
        raise OGR::UnsupportedOperation,
              'Your version of GDAL/OGR does not support OCTProj4Normalize'
      end
    end

    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      return unless pointer && !pointer.null?

      FFI::OGR::SRSAPI.OCTDestroyCoordinateTransformation(pointer)
    end

    # @return [OGR::SpatialReference]
    attr_reader :source_coordinate_system

    # @return [OGR::SpatialReference]
    attr_reader :destination_coordinate_system

    # @return [FFI::Pointer] C pointer that represents the CoordinateTransformation.
    attr_reader :c_pointer

    # @param source_srs [OGR::SpatialReference]
    # @param destination_srs [OGR::SpatialReference]
    def initialize(source_srs, destination_srs)
      source_ptr = GDAL._pointer(OGR::SpatialReference, source_srs)
      destination_ptr = GDAL._pointer(OGR::SpatialReference, destination_srs)

      # Input spatial reference system objects are assigned by copy (calling clone() method)
      # and no ownership transfer occurs.
      # NOTE: In GDAL 3, this will cause the GDAL error handler to raise a
      # GDAL::Error; in < 3, this just returns a null pointer, then gets handled
      # by the null-pointer check below.
      pointer = FFI::OGR::SRSAPI.OCTNewCoordinateTransformation(source_ptr, destination_ptr)

      raise GDAL::Error, 'Unable to create coordinate transformation' if pointer.null?

      @c_pointer = pointer
    end

    # Deletes the object and deallocates all related C resources.
    def destroy!
      CoordinateTransformation.release(@c_pointer)

      @c_pointer = nil
    end

    # Transforms points in the +#source_coordinate_system+ space to points in the
    # +#destination_coordinate_system+ (given in {#initialize}).
    #
    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @return [Array<Array<Float>,Array<Float>,Array<Float>>] [[x1, x2, etc], [y1, y2, etc]]
    #   Will include a 3rd array of Z values if z vertices are given.
    def transform(x_vertices, y_vertices, z_vertices = [])
      _transform(x_vertices, y_vertices, z_vertices) do |point_count, x_ptr, y_ptr, z_ptr|
        FFI::OGR::SRSAPI.OCTTransform(@c_pointer, point_count, x_ptr, y_ptr, z_ptr)
      end
    end

    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @return [Hash{points => Array<Array<Float>,Array<Float>,Array<Float>>, success_at => Array}]
    #   [[x1, y1], [x2, y2], etc]
    def transform_ex(x_vertices, y_vertices, z_vertices = [])
      success_ptr = nil

      point_array = _transform(x_vertices, y_vertices, z_vertices) do |point_count, x_ptr, y_ptr, z_ptr|
        success_ptr = FFI::MemoryPointer.new(:bool, point_count)
        FFI::OGR::SRSAPI.OCTTransformEx(@c_pointer, point_count, x_ptr, y_ptr, z_ptr, success_ptr)
      end

      successes = success_ptr.read_array_of_type(FFI::Type::BOOL, :read_char, point_array.first.length).map do |value|
        !value.zero?
      end

      { points: point_array, successes: successes }
    end

    private

    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @yieldparam point_count [Integer]
    # @yieldparam x_ptr [FFI::MemoryPointer]
    # @yieldparam y_ptr [FFI::MemoryPointer]
    # @yieldparam z_ptr [FFI::MemoryPointer]
    # @yieldreturn [Boolean]
    # @return [Array<Array<Float>,Array<Float>,Array<Float>>] [[x1, x2, etc], [y1, y2, etc]]
    #   Will include a 3rd array of Z values if z vertices are given.
    def _transform(x_vertices, y_vertices, z_vertices = [])
      x_ptr, y_ptr, z_ptr = init_transform_pointers(x_vertices, y_vertices, z_vertices)
      point_count = [x_vertices.length, y_vertices.length, z_vertices.length].max

      result = yield point_count, x_ptr, y_ptr, z_ptr

      # TODO: maybe this should raise?
      return false unless result

      x_vals = x_ptr.read_array_of_double(x_vertices.size)
      y_vals = y_ptr.read_array_of_double(y_vertices.size)
      z_vals = z_vertices.empty? ? nil : z_ptr.read_array_of_double(z_vertices.size)

      points = [x_vals, y_vals]
      points << z_vals unless z_vertices.empty?

      points
    end

    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @return [Array<FFI::Pointer>]
    def init_transform_pointers(x_vertices, y_vertices, z_vertices)
      x_ptr = FFI::MemoryPointer.new(:pointer, x_vertices.size)
      x_ptr.write_array_of_double(x_vertices)
      y_ptr = FFI::MemoryPointer.new(:pointer, y_vertices.size)
      y_ptr.write_array_of_double(y_vertices)

      if z_vertices.empty?
        z_ptr = nil
      else
        z_ptr = FFI::MemoryPointer.new(:pointer, z_vertices.size)
        z_ptr.write_array_of_double(z_vertices)
      end

      [x_ptr, y_ptr, z_ptr]
    end
  end
end
