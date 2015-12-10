module GDAL
  class WarpOperation
    # @return [FFI::Pointer]
    attr_reader :c_pointer

    # @param warp_options [GDAL::WarpOptions]
    def initialize(warp_options)
      @c_pointer = FFI::GDAL::Warper.GDALCreateWarpOperation(warp_options.c_struct)
      fail 'blort' if @c_pointer.null?
    end

    def destroy!
      FFI::GDAL::Warper.GDALDestroyWarpOperation(@c_pointer)
      @c_pointer = nil
    end

    # @param x_offset [Fixnum] X offset of the destination image.
    # @param y_offset [Fixnum] Y offset of the destination image.
    # @param x_size [Fixnum] X size (width) of the destination image.
    # @param y_size [Fixnum] Y size (height) of the destination image.
    def chunk_and_warp_image(x_offset, y_offset, x_size, y_size)
      !!FFI::GDAL::Warper.GDALChunkAndWarpImage(@c_pointer,
        x_offset,
        y_offset,
        x_size,
        y_size)
    end

    # @param x_offset [Fixnum] X offset of the destination image.
    # @param y_offset [Fixnum] Y offset of the destination image.
    # @param x_size [Fixnum] X size (width) of the destination image.
    # @param y_size [Fixnum] Y size (height) of the destination image.
    def chunk_and_warp_multi(x_offset, y_offset, x_size, y_size)
      FFI::GDAL::Warper.GDALChunkAndWarpMulti(@c_pointer,
        x_offset,
        y_offset,
        x_size,
        y_size)
    end

    # @param destination_x_offset [Fixnum] X offset of the destination image.
    # @param destination_y_offset [Fixnum] Y offset of the destination image.
    # @param destination_x_size [Fixnum] X size (width) of the destination image.
    # @param destination_y_size [Fixnum] Y size (height) of the destination image.
    # @param source_x_offset [Fixnum] X offset of the source image.
    # @param source_y_offset [Fixnum] Y offset of the source image.
    # @param source_x_size [Fixnum] X size (width) of the source image.
    # @param source_y_size [Fixnum] Y size (height) of the source image.
    def warp_region(destination_x_offset, destination_y_offset,
      destination_x_size, destination_y_size,
      source_x_offset, source_y_offset,
      source_x_size, source_y_size)
      !!FFI::GDAL::Warper.GDALWarpRegion(@c_pointer,
        destination_x_offset,
        destination_y_offset,
        destination_x_size,
        destination_y_size,
        source_x_offset,
        source_y_offset,
        source_x_size,
        source_y_size)
    end

    # @param destination_x_offset [Fixnum] X offset of the destination image.
    # @param destination_y_offset [Fixnum] Y offset of the destination image.
    # @param destination_x_size [Fixnum] X size (width) of the destination image.
    # @param destination_y_size [Fixnum] Y size (height) of the destination image.
    # @param buffer [FFI::Pointer]
    # @param data_type [FFI::GDAL::DataType]
    # @param source_x_offset [Fixnum] X offset of the source image.
    # @param source_y_offset [Fixnum] Y offset of the source image.
    # @param source_x_size [Fixnum] X size (width) of the source image.
    # @param source_y_size [Fixnum] Y size (height) of the source image.
    def warp_region_to_buffer(destination_x_offset, destination_y_offset,
      destination_x_size, destination_y_size,
      buffer, data_type,
      source_x_offset, source_y_offset,
      source_x_size, source_y_size)
      !!FFI::GDAL::Warper.GDALWarpRegionToBuffer(@c_pointer,
        destination_x_offset,
        destination_y_offset,
        destination_x_size,
        destination_y_size,
        buffer,
        data_type,
        source_x_offset,
        source_y_offset,
        source_x_size,
        source_y_size)
    end
  end
end
