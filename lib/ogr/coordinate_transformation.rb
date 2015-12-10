require 'narray'
require_relative 'spatial_reference'

module OGR
  class CoordinateTransformation
    # @param proj4_source [String]
    # @return [String]
    def self.proj4_normalize(proj4_source)
      if GDAL._supported?(:OCTProj4Normalize)
        FFI::GDAL.OCTProj4Normalize(proj4_source)
      end
    end

    # @return [OGR::SpatialReference]
    attr_reader :source_coordinate_system

    # @return [OGR::SpatialReference]
    attr_reader :destination_coordinate_system

    # @return [FFI::Pointer] C pointer that represents the CoordinateTransformation.
    attr_reader :c_pointer

    def initialize(source_srs, destination_srs)
      source_ptr = GDAL._pointer(OGR::SpatialReference, source_srs)
      destination_ptr = GDAL._pointer(OGR::SpatialReference, destination_srs)
      @c_pointer = FFI::OGR::SRSAPI.OCTNewCoordinateTransformation(source_ptr, destination_ptr)

      if @c_pointer.null?
        fail OGR::Failure, 'Unable to create coordinate transformation'
      end
    end

    # Deletes the object and deallocates all related resources.
    def destroy!
      FFI::OGR::SRSAPI.OCTDestroyCoordinateTransformation(@c_pointer)
    end

    # Transforms points in the +source_srs+ space to points in the
    # +destination_space+ (given in .create).
    #
    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @return [Array<Array<Float>,Array<Float>,Array<Float>>] [[x1, y1], [x2,
    #   y2], etc]
    def transform(x_vertices, y_vertices, z_vertices = [])
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

      point_count = x_vertices.size + y_vertices.size + z_vertices.size

      result = FFI::OGR::SRSAPI.OCTTransform(@c_pointer, point_count,
        x_ptr, y_ptr, z_ptr)

      # maybe this should raise?
      return false unless result

      x_vals = x_ptr.read_array_of_double
      y_vals = y_ptr.read_array_of_double
      z_vals = z_vertices.empty? ? nil : z_ptr.read_array_of_double

      points = if z_vertices.empty?
                 NMatrix[x_vals, y_vals]
               else
                 NMatrix[x_vals, y_vals, z_vals]
               end

      points.transpose.to_a
    end
  end
end
