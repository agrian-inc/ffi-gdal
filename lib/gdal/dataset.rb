# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require 'uri'
require_relative '../gdal'
require_relative '../ogr'
require_relative 'major_object'
require_relative 'dataset_mixins/matching'
require_relative 'dataset_mixins/algorithm_methods'
require_relative 'dataset_mixins/warp_methods'

module GDAL
  # A set of associated raster bands and info common to them all.  It's also
  # responsible for the georeferencing transform and coordinate system
  # definition of all bands.
  class Dataset
    extend T::Sig
    include MajorObject
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
    # @param shared [Boolean] Whether or not to open using GDALOpenShared
    #   vs GDALOpen. Defaults to +true+.
    # @return [GDAL::Dataset, Object] If no block is given, this returns the
    #   GDAL::Dataset. If a block is given, this returns what the block returns.
    sig { params(path: String, access_flag: String, shared: T::Boolean).returns(GDAL::Dataset) }
    def self.open(path, access_flag, shared: true)
      ds = new(path, access_flag, shared_open: shared)

      if block_given?
        result = yield ds
        ds.close
        result
      else
        ds
      end
    end

    # Copy all dataset raster data.
    #
    # This function copies the complete raster contents of one dataset to
    # another similarly configured dataset. The source and destination dataset
    # must have the same number of bands, and the same width and height. The
    # bands do not have to have the same data type.
    #
    # This function is primarily intended to support implementation of driver
    # specific CreateCopy() functions. It implements efficient copying, in
    # particular "chunking" the copy in substantial blocks and, if appropriate,
    # performing the transfer in a pixel interleaved fashion.
    #
    # @param source [GDAL::Dataset, FFI::Pointer]
    # @param destination [GDAL::Dataset, FFI::Pointer]
    # @param options [Hash]
    # @option options interleave: 'pixel'
    # @option options compressed: true
    # @option options skip_holes: true
    # @param progress_function [Proc]
    # @raise [GDAL::Error]
    sig do
      params(source: T.any(FFI::Pointer, GDAL::Dataset),
             destination: T.any(FFI::Pointer, GDAL::Dataset),
             options: T::Hash[T.any(String, Symbol), Object],
             progress_function: T.any(
               NilClass,
               T.proc.params(completion_ratio: Float,
                             message: T.any(NilClass, String),
                             progress_arg: T.any(NilClass, Object))
               .returns(T::Boolean)
             ))
        .void
    end
    def self.copy_whole_raster(source, destination, options = {}, progress_function = nil)
      source_ptr = GDAL._pointer(GDAL::Dataset, source, autorelease: false)
      dest_ptr = GDAL._pointer(GDAL::Dataset, destination, autorelease: false)
      options_ptr = GDAL::Options.pointer(options)

      GDAL::CPLErrorHandler.manually_handle('Unable to copy whole raster') do
        FFI::GDAL::GDAL.GDALDatasetCopyWholeRaster(source_ptr, dest_ptr, options_ptr, progress_function, nil)
      end
    end

    # @param dataset [GDAL::Dataset]
    # @return [FFI::AutoPointer]
    sig do
      params(dataset: T.any(FFI::Pointer, GDAL::Dataset),
             warn_on_nil: T::Boolean)
        .returns(FFI::AutoPointer)
    end
    def self.new_pointer(dataset, warn_on_nil: true)
      ptr = GDAL._pointer(GDAL::Dataset, dataset, warn_on_nil: warn_on_nil, autorelease: false)

      FFI::AutoPointer.new(ptr, Dataset.method(:release))
    end

    # @param pointer [FFI::Pointer]
    sig { params(pointer: FFI::Pointer).void }
    def self.release(pointer)
      return if pointer.null?

      FFI::GDAL::GDAL.GDALClose(pointer)
    end

    #---------------------------------------------------------------------------
    # Instance methods
    #---------------------------------------------------------------------------

    # @return [FFI::Pointer] Pointer to the GDALDatasetH that's represented by
    #   this Ruby object.
    sig { returns(FFI::Pointer) }
    attr_reader :c_pointer

    # @param path_or_pointer [String, FFI::Pointer] Path to the file that
    #   contains the dataset or a pointer to the dataset. If it's a path, it can
    #   be a local file or a URL.
    # @param access_flag [String] 'r' or 'w'.
    # @param shared_open [Boolean] Whether or not to open using GDALOpenShared
    #   vs GDALOpen. Defaults to +true+.
    sig { params(path_or_pointer: T.any(String, FFI::Pointer), access_flag: String, shared_open: T::Boolean).void }
    def initialize(path_or_pointer, access_flag, shared_open: true)
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

      raise OpenFailure, path_or_pointer if @c_pointer.null?

      @geo_transform = nil
      @spatial_reference = nil
      @raster_bands = Array.new(raster_count)
    end

    # Close the dataset.
    sig { void }
    def close
      Dataset.release(@c_pointer)

      @c_pointer = nil
    end

    # @return [Symbol]
    sig { returns(Symbol) }
    def access_flag
      flag = FFI::GDAL::GDAL.GDALGetAccess(@c_pointer)

      FFI::GDAL::GDAL::Access[flag]
    end

    # @return [GDAL::Driver] The driver to be used for working with this
    #   dataset.
    sig { returns(GDAL::Driver) }
    def driver
      driver_ptr = FFI::GDAL::GDAL.GDALGetDatasetDriver(@c_pointer)

      Driver.new(driver_ptr)
    end

    # Fetches all files that form the dataset.
    # @return [Array<String>]
    sig { returns(T::Array[String]) }
    def file_list
      list_pointer = FFI::GDAL::GDAL.GDALGetFileList(@c_pointer)
      return [] if list_pointer.null?

      file_list = list_pointer.get_array_of_string(0)
      FFI::CPL::String.CSLDestroy(list_pointer)

      file_list
    end

    # Flushes all write-cached data to disk.
    sig { void }
    def flush_cache
      FFI::GDAL::GDAL.GDALFlushCache(@c_pointer)
    end

    # @return [Integer]
    sig { returns(Integer) }
    def raster_x_size
      return 0 if null?

      FFI::GDAL::GDAL.GDALGetRasterXSize(@c_pointer)
    end

    # @return [Integer]
    sig { returns(Integer) }
    def raster_y_size
      return 0 if null?

      FFI::GDAL::GDAL.GDALGetRasterYSize(@c_pointer)
    end

    # @return [Integer]
    sig { returns(Integer) }
    def raster_count
      return 0 if null?

      FFI::GDAL::GDAL.GDALGetRasterCount(@c_pointer)
    end

    # @param raster_index [Integer]
    # @return [GDAL::RasterBand]
    sig { params(raster_index: Integer).returns(GDAL::RasterBand) }
    def raster_band(raster_index)
      if raster_index > raster_count
        raise GDAL::InvalidRasterBand, "Invalid raster band number '#{raster_index}'. Must be <= #{raster_count}"
      end

      raster_band_ptr = FFI::GDAL::GDAL.GDALGetRasterBand(@c_pointer, raster_index)
      raster_band_ptr.autorelease = false

      GDAL::RasterBand.new(raster_band_ptr, self)
    end

    # @param type [FFI::Enum] One of FFI::GDAL::GDAL::DataType.
    # @param options [Hash]
    # @raise [GDAL::Error]
    # @return [GDAL::RasterBand, nil]
    sig { params(type: FFI::Enum, options: T::Hash[T.any(String, Symbol), Object]).returns(GDAL::RasterBand) }
    def add_band(type, **options)
      options_ptr = GDAL::Options.pointer(options)

      GDAL::CPLErrorHandler.manually_handle('Unable to add band') do
        FFI::GDAL::GDAL.GDALAddBand(@c_pointer, type, options_ptr)
      end

      raster_band(raster_count)
    end

    # Adds a mask band to the dataset.
    #
    # @param flags [Array<Symbol>, Symbol] Any of the :GMF symbols.
    # @raise [GDAL::Error]
    sig { params(flags: T::Array[Symbol]).void }
    def create_mask_band(*flags)
      flag_value = parse_mask_flag_symbols(T.unsafe(flags))

      GDAL::CPLErrorHandler.manually_handle('Unable to create Dataset mask band') do
        FFI::GDAL::GDAL.GDALCreateDatasetMaskBand(@c_pointer, flag_value)
      end
    end

    # @return [String]
    sig { returns(String) }
    def projection
      # Returns a pointer to an internal projection reference string. It should
      # not be altered, freed or expected to last for long.
      proj, ptr = FFI::GDAL::GDAL.GDALGetProjectionRef(@c_pointer)
      ptr.autorelease = false

      proj || ''
    end

    # @param new_projection [String] Should be in WKT or PROJ.4 format.
    # @raise [GDAL::Error]
    sig { params(new_projection: String).void }
    def projection=(new_projection)
      GDAL::CPLErrorHandler.manually_handle('Unable to set projection') do
        FFI::GDAL::GDAL.GDALSetProjection(@c_pointer, new_projection.to_s)
      end
    end

    # @return [GDAL::GeoTransform]
    # @raise [GDAL::Error]
    sig { returns(GDAL::GeoTransform) }
    def geo_transform
      return @geo_transform if @geo_transform

      geo_transform_pointer = GDAL::GeoTransform.new_pointer

      GDAL::CPLErrorHandler.manually_handle('Unable to get geo_transform') do
        FFI::GDAL::GDAL.GDALGetGeoTransform(@c_pointer, geo_transform_pointer)
      end

      @geo_transform = GeoTransform.new(geo_transform_pointer)
    end

    # @param new_transform [GDAL::GeoTransform, FFI::Pointer]
    # @return [GDAL::GeoTransform]
    # @raise [GDAL::Error]
    sig { params(new_transform: GDAL::GeoTransform).returns(GDAL::GeoTransform) }
    def geo_transform=(new_transform)
      new_pointer = GDAL._pointer(GDAL::GeoTransform, new_transform)

      GDAL::CPLErrorHandler.manually_handle('Unable to set geo_transform') do
        FFI::GDAL::GDAL.GDALSetGeoTransform(@c_pointer, new_pointer)
      end

      @geo_transform = new_transform.is_a?(FFI::Pointer) ? GeoTransform.new(new_pointer) : new_transform
    end

    # @return [Integer]
    sig { returns(Integer) }
    def gcp_count
      return 0 if null?

      FFI::GDAL::GDAL.GDALGetGCPCount(@c_pointer)
    end

    # @return [String]
    sig { returns(String) }
    def gcp_projection
      return '' if null?

      proj, ptr = FFI::GDAL::GDAL.GDALGetGCPProjection(@c_pointer)
      ptr.autorelease = false

      proj
    end

    # @return [FFI::GDAL::GCP]
    sig { returns(FFI::GDAL::GCP) }
    def gcps
      return FFI::GDAL::GCP.new if null?

      gcp_array_pointer = FFI::GDAL::GDAL.GDALGetGCPs(@c_pointer)

      if gcp_array_pointer.null?
        FFI::GDAL::GCP.new
      else
        FFI::GDAL::GCP.new(gcp_array_pointer)
      end
    end

    # @param resampling [String, Symbol] One of:
    #   * :nearest          - Nearest neighbor resampling
    #   * :gauss            - Gaussian kernel resampling
    #   * :cubic            - Cubic convolution resampling
    #   * :average          - Average of all non-NODATA
    #   * :mode             - Selects the value that occurs most often
    #   * :average_magphase - Averages complex data in mag/phase space
    #   * :none
    # @param overview_levels [Array<Integer>] The list of overview decimation
    #   factors to build.
    # @param band_numbers [NilClass, Array<Integer>] The numbers of the bands to build
    #   overviews from.
    # @see http://www.gdal.org/gdaladdo.html
    # @raise [GDAL::Error]
    sig do
      params(resampling: T.any(String, Symbol),
             overview_levels: T::Array[Integer],
             progress_function: T.any(
               NilClass,
               T.proc.params(completion_ratio: Float,
                             message: T.any(NilClass, String),
                             progress_arg: T.any(NilClass, Object))
               .returns(T::Boolean)
             ),
             band_numbers: T.any(T::Array[Integer], NilClass))
        .void
    end
    def build_overviews(resampling, overview_levels, progress_function = nil, band_numbers: nil)
      resampling_string = case resampling
                          when String
                            resampling.upcase
                          when Symbol
                            resampling.to_s.upcase
                          end

      overview_levels_ptr = FFI::MemoryPointer.new(:int, overview_levels.size)
      overview_levels_ptr.write_array_of_int(overview_levels)
      band_numbers_ptr, band_count = band_numbers_args(band_numbers)

      GDAL::CPLErrorHandler.manually_handle('Unable to build overviews') do
        FFI::GDAL::GDAL.GDALBuildOverviews(
          @c_pointer,
          resampling_string,
          overview_levels.size,
          overview_levels_ptr,
          band_count,
          band_numbers_ptr,
          progress_function,
          nil
        )
      end
    end

    # @param access_flag [String] 'r' or 'w'.
    # @param buffer [FFI::MemoryPointer] The pointer to the data to read/write
    #   to the dataset.
    # @param x_size [Integer] If not given, uses {{#raster_x_size}}.
    # @param y_size [Integer] If not given, uses {{#raster_y_size}}.
    # @param x_offset [Integer] The pixel number in the line to start operating
    #   on. Note that when using this, {#x_size} - +x_offset+ should be >= 0,
    #   otherwise this means you're telling the method to read past the end of
    #   the line. Defaults to 0.
    # @param y_offset [Integer] The line number to start operating on. Note that
    #   when using this, {#y_size} - +y_offset+ should be >= 0, otherwise this
    #   means you're telling the method to read more lines than the raster has.
    #   Defaults to 0.
    # @param buffer_x_size [Integer] The width of the buffer image in which to
    #   read/write the raster data into/from. Typically this should be the same
    #   size as +x_size+; if it's different, GDAL will resample accordingly.
    # @param buffer_y_size [Integer] The height of the buffer image in which to
    #   read/write the raster data into/from. Typically this should be the same
    #   size as +y_size+; if it's different, GDAL will resample accordingly.
    # @param buffer_data_type [FFI::GDAL::GDAL::DataType] Can be used to convert the
    #   data to a different type. You must account for this when reading/writing
    #   to/from your buffer--your buffer size must be +buffer_x_size+ *
    #   +buffer_y_size+.
    # @param band_numbers [Array<Integer>] The numbers of the bands to do IO on.
    #   Pass +nil+ defaults to choose the first band.
    # @param pixel_space [Integer] The byte offset from the start of one pixel
    #   value in the buffer to the start of the next pixel value within a line.
    #   If defaulted (0), the size of +buffer_data_type+ is used.
    # @param line_space [Integer] The byte offset from the start of one line in
    #   the buffer to the start of the next. If defaulted (0), the size of
    #   +buffer_data_type+ * +buffer_x_size* is used.
    # @param band_space [Integer] The byte offset from the start of one band's
    #   data to the start of the next. If defaulted (0), the size of
    #   +line_space+ * +buffer_y_size* is used.
    # @return [FFI::MemoryPointer] The buffer that was passed in.
    # @raise [GDAL::Error] On failure.
    # rubocop:disable Metrics/ParameterLists
    sig do
      params(access_flag: String,
             buffer: T.any(NilClass, FFI::MemoryPointer),
             x_size: T.any(Integer, NilClass),
             y_size: T.any(Integer, NilClass),
             x_offset: Integer,
             y_offset: Integer,
             buffer_x_size: T.any(Integer, NilClass),
             buffer_y_size: T.any(Integer, NilClass),
             buffer_data_type: T.any(FFI::Enum, NilClass),
             band_numbers: T.any(T::Array[Integer], NilClass),
             pixel_space: Integer,
             line_space: Integer,
             band_space: Integer)
        .returns(FFI::MemoryPointer)
    end
    def raster_io(access_flag, buffer = nil,
      x_size: nil, y_size: nil, x_offset: 0, y_offset: 0,
      buffer_x_size: nil, buffer_y_size: nil, buffer_data_type: nil,
      band_numbers: nil,
      pixel_space: 0, line_space: 0, band_space: 0)
      x_size ||= raster_x_size
      y_size ||= raster_y_size
      buffer_x_size ||= x_size
      buffer_y_size ||= y_size
      buffer_data_type ||= raster_band(1).data_type

      band_numbers_ptr, band_count = band_numbers_args(band_numbers)
      band_count = raster_count if band_count.zero?

      buffer ||= GDAL._pointer_from_data_type(buffer_data_type, buffer_x_size * buffer_y_size * band_count)

      gdal_access_flag = GDAL._gdal_access_flag(access_flag)

      min_buffer_size = valid_min_buffer_size(buffer_data_type, buffer_x_size, buffer_y_size)

      unless buffer.size >= min_buffer_size
        raise GDAL::BufferTooSmall, "Buffer size (#{buffer.size}) too small (#{min_buffer_size})"
      end

      GDAL::CPLErrorHandler.manually_handle('Unable to perform raster band IO') do
        FFI::GDAL::GDAL::GDALDatasetRasterIO(
          @c_pointer,                     # hDS
          gdal_access_flag,               # eRWFlag
          x_offset,                       # nXOff
          y_offset,                       # nYOff
          x_size,                         # nXSize
          y_size,                         # nYSize
          buffer,                         # pData
          buffer_x_size,                  # nBufXSize
          buffer_y_size,                  # nBufYSize
          buffer_data_type,               # eBufType
          band_count,                     # nBandCount
          band_numbers_ptr,               # panBandMap (WTH is this?)
          pixel_space,                    # nPixelSpace
          line_space,                     # nLineSpace
          band_space                      # nBandSpace
        )
      end

      buffer
    end
    # rubocop:enable Metrics/ParameterLists

    # Creates a OGR::SpatialReference object from the dataset's projection.
    #
    # @return [OGR::SpatialReference]
    sig { returns(T.any(NilClass, OGR::SpatialReference)) }
    def spatial_reference
      return @spatial_reference if @spatial_reference

      return nil if projection.empty?

      @spatial_reference = OGR::SpatialReference.new(projection)
    end

    private

    # Lets you pass in :GMF_ symbols that represent mask band flags and bitwise
    # ors them.
    #
    # @param flags [Symbol]
    # @return [Integer]
    sig { params(flags: T::Array[Symbol]).returns(Integer) }
    def parse_mask_flag_symbols(*flags)
      flags.reduce(0) do |result, flag|
        result | case flag
                 when :GMF_ALL_VALID then 0x01
                 when :GMF_PER_DATASET then 0x02
                 when :GMF_PER_ALPHA then 0x04
                 when :GMF_NODATA then 0x08
                 else 0
                 end
      end
    end

    # @param buffer_data_type [FFI::GDAL::GDAL::DataType]
    # @param x_buffer_size [Integer]
    # @param y_buffer_size [Integer]
    # @return [Integer]
    sig { params(buffer_data_type: FFI::Enum, x_buffer_size: Integer, y_buffer_size: Integer).returns(Integer) }
    def valid_min_buffer_size(buffer_data_type, x_buffer_size, y_buffer_size)
      data_type_bytes = GDAL::DataType.size(buffer_data_type) / 8

      data_type_bytes * x_buffer_size * y_buffer_size
    end

    # Makes a pointer of +band_numbers+.
    #
    # @param band_numbers [Array<Integer>, NilClass]
    # @return [Array<FFI::MemoryPointer, Integer>]
    sig { params(band_numbers: T.any(T::Array[Integer], NilClass)).returns([FFI::MemoryPointer, Integer]) }
    def band_numbers_args(band_numbers)
      band_count = band_numbers&.size || 0
      ptr = FFI::MemoryPointer.new(:int, band_count)

      ptr.write_array_of_int(band_numbers) if band_numbers

      ptr.autorelease = false

      [ptr, band_count]
    end
  end
end
