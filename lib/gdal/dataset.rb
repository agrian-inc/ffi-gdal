require 'uri'
require_relative '../gdal'
require_relative '../ogr'
require_relative 'major_object'
require_relative 'dataset_mixins/extensions'
require_relative 'dataset_mixins/matching'
require_relative 'dataset_mixins/algorithm_methods'
require_relative 'dataset_mixins/warp_methods'

module GDAL
  # A set of associated raster bands and info common to them all.  It's also
  # responsible for the georeferencing transform and coordinate system
  # definition of all bands.
  class Dataset
    include MajorObject
    include DatasetMixins::Extensions
    include DatasetMixins::Matching
    include DatasetMixins::AlgorithmMethods
    include DatasetMixins::WarpMethods
    include GDAL::Logger

    ACCESS_FLAGS = {
      'r' => :GA_ReadOnly,
      'w' => :GA_Update
    }.freeze

    # @param path [String] Path to the file that contains the dataset.  Can be
    #   a local file or a URL.
    # @param access_flag [String] 'r' or 'w'.
    # @param shared_open [Boolean] Whether or not to open using GDALOpenShared
    #   vs GDALOpen. Defaults to +true+.
    def self.open(path, access_flag, shared_open = true)
      ds = new(path, access_flag, shared_open)

      if block_given?
        result = yield ds
        ds.close
        result
      else
        ds
      end
    end

    #---------------------------------------------------------------------------
    # Instance methods
    #---------------------------------------------------------------------------

    # @return [FFI::Pointer] Pointer to the GDALDatasetH that's represented by
    #   this Ruby object.
    attr_reader :c_pointer

    # @param path_or_pointer [String, FFI::Pointer] Path to the file that
    #   contains the dataset or a pointer to the dataset. If it's a path, it can
    #   be a local file or a URL.
    # @param access_flag [String] 'r' or 'w'.
    # @param shared_open [Boolean] Whether or not to open using GDALOpenShared
    #   vs GDALOpen. Defaults to +true+.
    def initialize(path_or_pointer, access_flag, shared_open = true)
      @c_pointer =
        if path_or_pointer.is_a? String
          file_path = begin
            uri = URI.parse(path_or_pointer)
            uri.scheme.nil? ? ::File.expand_path(path_or_pointer) : path_or_pointer
          rescue URI::InvalidURIError
            path_or_pointer
          end

          if shared_open
            FFI::GDAL::GDAL.GDALOpenShared(file_path, ACCESS_FLAGS[access_flag])
          else
            FFI::GDAL::GDAL.GDALOpen(file_path, ACCESS_FLAGS[access_flag])
          end
        else
          path_or_pointer
        end

      fail OpenFailure, path_or_pointer if @c_pointer.null?

      @geo_transform = nil
      @spatial_reference = nil
      @raster_bands = Array.new(raster_count)
    end

    # Close the dataset.
    def close
      return unless @c_pointer

      FFI::GDAL::GDAL.GDALClose(@c_pointer)
      @c_pointer = nil
    end

    # @return [Symbol]
    def access_flag
      return nil if null?

      flag = FFI::GDAL::GDAL.GDALGetAccess(@c_pointer)

      FFI::GDAL::GDAL::Access[flag]
    end

    # @return [GDAL::Driver] The driver to be used for working with this
    #   dataset.
    def driver
      driver_ptr = FFI::GDAL::GDAL.GDALGetDatasetDriver(@c_pointer)

      Driver.new(driver_ptr)
    end

    # Fetches all files that form the dataset.
    # @return [Array<String>]
    def file_list
      list_pointer = FFI::GDAL::GDAL.GDALGetFileList(@c_pointer)
      return [] if list_pointer.null?
      file_list = list_pointer.get_array_of_string(0)
      FFI::CPL::String.CSLDestroy(list_pointer)

      file_list
    end

    # Flushes all write-cached data to disk.
    def flush_cache
      FFI::GDAL::GDAL.GDALFlushCache(@c_pointer)
    end

    # @return [Fixnum]
    def raster_x_size
      return nil if null?

      FFI::GDAL::GDAL.GDALGetRasterXSize(@c_pointer)
    end

    # @return [Fixnum]
    def raster_y_size
      return nil if null?

      FFI::GDAL::GDAL.GDALGetRasterYSize(@c_pointer)
    end

    # @return [Fixnum]
    def raster_count
      return 0 if null?

      FFI::GDAL::GDAL.GDALGetRasterCount(@c_pointer)
    end

    # @param raster_index [Fixnum]
    # @return [GDAL::RasterBand]
    def raster_band(raster_index)
      if raster_index > raster_count
        fail GDAL::InvalidRasterBand, "Invalid raster band number '#{raster_index}'. Must be <= #{raster_count}"
      end

      raster_band_ptr = FFI::GDAL::GDAL.GDALGetRasterBand(@c_pointer, raster_index)

      GDAL::RasterBand.new(raster_band_ptr)
    end

    # @param type [FFI::GDAL::GDAL::DataType]
    # @param options [Hash]
    # @return [GDAL::RasterBand, nil]
    def add_band(type, **options)
      options_ptr = GDAL::Options.pointer(options)
      FFI::GDAL::GDAL.GDALAddBand(@c_pointer, type, options_ptr)

      raster_band(raster_count)
    end

    # Adds a mask band to the dataset.
    #
    # @param flags [Fixnum] Any of of the GDAL::RasterBand flags.
    # @return [Boolean]
    def create_mask_band(flags)
      !!FFI::GDAL::GDAL.GDALCreateDatasetMaskBand(@c_pointer, flags)
    end

    # @return [String]
    def projection
      FFI::GDAL::GDAL.GDALGetProjectionRef(@c_pointer) || ''
    end

    # @param new_projection [String]
    # @return [Boolean]
    def projection=(new_projection)
      FFI::GDAL::GDAL.GDALSetProjection(@c_pointer, new_projection.to_s)
    end

    # @return [GDAL::GeoTransform]
    def geo_transform
      return @geo_transform if @geo_transform

      geo_transform_pointer = GDAL::GeoTransform.new_pointer
      FFI::GDAL::GDAL.GDALGetGeoTransform(@c_pointer, geo_transform_pointer)

      @geo_transform = GeoTransform.new(geo_transform_pointer)
    end

    # @param new_transform [GDAL::GeoTransform]
    # @return [GDAL::GeoTransform]
    def geo_transform=(new_transform)
      new_pointer = GDAL._pointer(GDAL::GeoTransform, new_transform)
      FFI::GDAL::GDAL.GDALSetGeoTransform(@c_pointer, new_pointer)

      @geo_transform = GeoTransform.new(new_pointer)
    end

    # @return [Fixnum]
    def gcp_count
      return 0 if null?

      FFI::GDAL::GDAL.GDALGetGCPCount(@c_pointer)
    end

    # @return [String]
    def gcp_projection
      return '' if null?

      FFI::GDAL::GDAL.GDALGetGCPProjection(@c_pointer)
    end

    # @return [FFI::GDAL::GCP]
    def gcps
      return FFI::GDAL::GCP.new if null?

      gcp_array_pointer = FFI::GDAL::GDAL.GDALGetGCPs(@c_pointer)

      if gcp_array_pointer.null?
        FFI::GDAL::GCP.new
      else
        FFI::GDAL::GCP.new(gcp_array_pointer)
      end
    end

    # @return [Fixnum]
    def layer_count
      fail GDAL::UnsupportedOperation unless GDAL._supported?(:GDALDatasetGetLayerCount)

      FFI::GDAL::GDAL.GDALDatasetGetLayerCount(@c_pointer)
    end

    # @param resampling [String, Symbol] One of:
    #   * :nearest
    #   * :gauss
    #   * :cubic
    #   * :average
    #   * :mode
    #   * :average_magphase
    #   * :none
    # @param overview_levels [Array<Fixnum>] The list of overview decimation
    #   factors to build.
    # @param band_numbers [Array<Fixnum>] The numbers of the bands to build
    #   overviews from.
    def build_overviews(resampling, overview_levels, band_numbers = nil, &progress)
      resampling_string = if resampling.is_a? String
                            resampling.upcase
                          elsif resampling.is_a? Symbol
                            resampling.to_s.upcase
                          end

      overview_levels_ptr = FFI::MemoryPointer.new(:int, overview_levels.size)
      overview_levels_ptr.write_array_of_int(overview_levels)

      if band_numbers
        band_count = band_numbers.size
        band_numbers_ptr = FFI::MemoryPointer.new(:int, band_count)
        band_numbers_ptr.write_array_of_int(band_numbers)
      else
        band_numbers_ptr = nil
        band_count = nil
      end

      !!FFI::GDAL::GDAL.GDALBuildOverviews(
        @c_pointer,
        resampling_string,
        overview_levels.size,
        overview_levels_ptr,
        band_count,
        band_numbers_ptr,
        progress,
        nil
      )
    end

    # @param access_flag [String] 'r' or 'w'
    # @param data_ptr [FFI::MemoryPointer] The pointer to the data to write to
    #   the dataset.
    # @param x_size [Fixnum] If not given, uses #raster_x_size.
    # @param y_size [Fixnum] If not given, uses #raster_y_size.
    # @param data_type [FFI::GDAL::GDAL::DataType]
    # @param band_count [Fixnum] The number of bands to create in the raster.
    # @param pixel_space
    def raster_io(access_flag, data_ptr,
      x_size: nil, y_size: nil, x_offset: 0, y_offset: 0,
      data_type: :GDT_Byte, band_count: 1,
      pixel_space: 0, line_space: 0, band_space: 0)
      x_size ||= raster_x_size
      y_size ||= raster_y_size

      gdal_access_flag = GDAL._gdal_access_flag(access_flag)
      x_buffer_size = x_size
      y_buffer_size = y_size

      !!FFI::GDAL::GDAL::GDALDatasetRasterIO(
        @c_pointer,                     # hDS
        gdal_access_flag,               # eRWFlag
        x_offset,                       # nXOff
        y_offset,                       # nYOff
        x_size,                         # nXSize
        y_size,                         # nYSize
        data_ptr,                       # pData
        x_buffer_size,                  # nBufXSize
        y_buffer_size,                  # nBufYSize
        data_type,                      # eBufType
        band_count,                     # nBandCount
        nil,                            # panBandMap (WTH is this?)
        pixel_space,                    # nPixelSpace
        line_space,                     # nLineSpace
        band_space                      # nBandSpace
      )
    end
  end
end
