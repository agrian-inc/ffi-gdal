# typed: false
# frozen_string_literal: true

require_relative '../gdal'

module GDAL
  class GeoTransform
    # @return [FFI::MemoryPointer] A pointer that can be used to hold a GeoTransform.
    def self.new_pointer
      FFI::MemoryPointer.new(:double, 6)
    end

    # @return [FFI::Pointer] C pointer to the C geo-transform.
    attr_reader :c_pointer

    # @param [String] filename
    # @param [String] extension The file extension to use.  When nil, GDAL will
    #   try to derive it from the +filename+.
    # @return [GDAL::GeoTransform]
    def self.from_world_file(filename, extension = nil)
      gt_ptr = new_pointer

      result = if extension
                 FFI::GDAL::GDAL.GDALReadWorldFile(filename, extension, gt_ptr)
               else
                 FFI::GDAL::GDAL.GDALLoadWorldFile(filename, gt_ptr)
               end

      return nil unless result

      new(gt_ptr)
    end

    # @param geo_transform [FFI::Pointer]
    def initialize(geo_transform = nil)
      @c_pointer = geo_transform ? GDAL._pointer(GDAL::GeoTransform, geo_transform) : self.class.new_pointer

      self.pixel_width ||= 1.0
      self.pixel_height ||= 1.0
      self.x_rotation ||= 0.0
      self.y_rotation ||= 0.0
    end

    def null?
      @c_pointer.null?
    end

    # X-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "C".
    #
    # @return [Float]
    def x_origin
      return nil if null?

      @c_pointer[0].read_double
    end

    # @param new_x_origin [Float]
    def x_origin=(new_x_origin)
      @c_pointer[0].write_double(new_x_origin)
    end

    # AKA X-pixel size.
    # In wikipedia's World Map definition, this is "A".
    #
    # @return [Float]
    def pixel_width
      return nil if null?

      @c_pointer[1].read_double
    end

    # @param new_pixel_width [Float]
    def pixel_width=(new_pixel_width)
      @c_pointer[1].write_double(new_pixel_width)
    end

    # Rotation about the x-axis.
    # In wikipedia's World File definition, this is "B".
    #
    # @return [Float]
    def x_rotation
      return nil if null?

      @c_pointer[2].read_double
    end

    # @param new_x_rotation [Float]
    def x_rotation=(new_x_rotation)
      @c_pointer[2].write_double(new_x_rotation)
    end

    # Y-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "F".
    #
    # @return [Float]
    def y_origin
      return nil if null?

      @c_pointer[3].read_double
    end

    # @param new_y_origin [Float]
    def y_origin=(new_y_origin)
      @c_pointer[3].write_double(new_y_origin)
    end

    # Rotation about the y-axis.
    # In wikipedia's World Map definition, this is "D".
    #
    # @return [Float]
    def y_rotation
      return nil if null?

      @c_pointer[4].read_double
    end

    # @param new_y_rotation [Float]
    def y_rotation=(new_y_rotation)
      @c_pointer[4].write_double(new_y_rotation)
    end

    # AKA Y-pixel size.
    # In wikipedia's World Map definition, this is "E".
    #
    # @return [Float]
    def pixel_height
      return nil if null?

      @c_pointer[5].read_double
    end

    # @param new_pixel_height [Float]
    def pixel_height=(new_pixel_height)
      @c_pointer[5].write_double(new_pixel_height)
    end

    # Converts a (pixel, line) coordinate to a georeferenced (geo_x, geo_y)
    # location.  Uses the following algorithm:
    #
    #   geo_x = x_origin + (pixel * pixel_width) + (line * pixel_rotation)
    #   geo_y = y_origin + (pixel * y_rotation) + (line * pixel_height)
    #
    # This is also the same as doing:
    #
    #   geo_transform.invert.world_to_pixel(pixel, line)
    #
    # @param pixel [Float] Input pixel position.
    # @param line [Float] Input line position.
    # @return [Hash{x_geo => Float, y_geo => Float}]  +:x_geo+ is the
    # #   easting/longitude; +:y_geo+ is the northing/latitude.
    def apply_geo_transform(pixel, line)
      geo_x_ptr = FFI::MemoryPointer.new(:double)
      geo_y_ptr = FFI::MemoryPointer.new(:double)
      FFI::GDAL::GDAL.GDALApplyGeoTransform(@c_pointer, pixel, line, geo_x_ptr, geo_y_ptr)

      { x_geo: geo_x_ptr.read_double, y_geo: geo_y_ptr.read_double }
    end
    alias pixel_to_world apply_geo_transform

    # Composes this and the given geo_transform.  The resulting GeoTransform is
    # equivalent to applying both GeoTransforms to a point.
    #
    # @param other_geo_transform [GDAL::GeoTransform, FFI::Pointer]
    # @return [GDAL::GeoTransform]
    def compose(other_geo_transform)
      other_ptr = GDAL._pointer(GDAL::GeoTransform, other_geo_transform)

      raise GDAL::NullObject, "Unable to access pointer for '#{other_geo_transform}'" unless other_ptr

      new_gt_ptr = self.class.new_pointer
      FFI::GDAL::GDAL.GDALComposeGeoTransforms(@c_pointer, other_ptr, new_gt_ptr)
      return nil if new_gt_ptr.null?

      GDAL::GeoTransform.new(new_gt_ptr)
    end

    # Inverts the current 3x2 set of coefficients and returns a new GeoTransform.
    # Useful for converting from the GeoTransform equation from pixel to geo to
    # being geo to pixel.
    #
    # @return [GDAL::GeoTransform]
    def invert
      new_geo_transform_ptr = self.class.new_pointer
      success = FFI::GDAL::GDAL.GDALInvGeoTransform(@c_pointer, new_geo_transform_ptr)
      return nil unless success

      self.class.new(new_geo_transform_ptr)
    end

    # @param raster_filename [String] The target raster file.
    # @param world_extension [String]
    # @return [Boolean]
    def to_world_file(raster_filename, world_extension)
      FFI::GDAL::GDAL.GDALWriteWorldFile(raster_filename, world_extension, @c_pointer)
    end
  end
end
