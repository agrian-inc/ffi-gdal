# typed: false
# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'
require 'narray'
require_relative '../gdal'
require_relative 'raster_band_mixins/algorithm_methods'
require_relative 'major_object'

module GDAL
  class RasterBand
    include MajorObject
    include GDAL::Logger
    include RasterBandMixins::AlgorithmMethods

    ALL_VALID = 0x01
    PER_DATASET = 0x02
    ALPHA = 0x04
    NODATA = 0x08

    # @return [FFI::Pointer] C pointer to the C raster band.
    attr_reader :c_pointer

    # @return [GDAL::Dataset] The dataset that owns this RasterBand.
    attr_reader :dataset

    # @param raster_band [GDAL::RasterBand, FFI::Pointer]
    def initialize(raster_band, dataset = nil)
      @c_pointer = GDAL._pointer(GDAL::RasterBand, raster_band, autorelease: false)

      # Init the dataset too--the dataset owns the raster band, so when the dataset
      # gets closed, the raster band gets cleaned up. Storing a reference to the
      # dataset here ensures the underlying raster band doesn't get pulled out
      # from under the Ruby object that represents it.
      @dataset = dataset || init_dataset
    end

    # @raise [GDAL::Error]
    def flush_cache
      GDAL::CPLErrorHandler.manually_handle('Unable to flush cache') do
        FFI::GDAL::GDAL.GDALFlushRasterCache(@c_pointer)
      end
    end

    # The raster width in pixels.
    #
    # @return [Integer]
    def x_size
      FFI::GDAL::GDAL.GDALGetRasterBandXSize(@c_pointer)
    end

    # The raster height in pixels.
    #
    # @return [Integer]
    def y_size
      FFI::GDAL::GDAL.GDALGetRasterBandYSize(@c_pointer)
    end

    # The type of access to the raster band this object currently has.
    #
    # @return [Symbol] Either :GA_Update or :GA_ReadOnly.
    def access_flag
      FFI::GDAL::GDAL.GDALGetRasterAccess(@c_pointer)
    end

    # The number of band within the associated dataset that this band
    # represents.
    #
    # @return [Integer]
    def number
      FFI::GDAL::GDAL.GDALGetBandNumber(@c_pointer)
    end

    # @return [Symbol] One of FFI::GDAL::GDAL::ColorInterp.
    def color_interpretation
      FFI::GDAL::GDAL.GDALGetRasterColorInterpretation(@c_pointer)
    end

    # @param new_color_interp [FFI::GDAL::GDAL::ColorInterp]
    # @raise [GDAL::Error]
    def color_interpretation=(new_color_interp)
      GDAL::CPLErrorHandler.manually_handle('Unable to set color interpretation') do
        FFI::GDAL::GDAL.GDALSetRasterColorInterpretation(@c_pointer, new_color_interp)
      end
    end

    # Gets the associated GDAL::ColorTable. Note that it remains owned by the
    # RasterBand and cannot be modified.
    #
    # @return [GDAL::ColorTable]
    def color_table
      color_table_ptr = FFI::GDAL::GDAL.GDALGetRasterColorTable(@c_pointer)
      color_table_ptr.autorelease = false

      return nil if color_table_ptr.null?

      ColorTable.new(color_table_ptr)
    end

    # @param new_color_table [GDAL::ColorTable]
    # @raise [GDAL::Error]
    def color_table=(new_color_table)
      color_table_pointer = GDAL::ColorTable.new_pointer(new_color_table)

      GDAL::CPLErrorHandler.manually_handle('Unable to set color table') do
        FFI::GDAL::GDAL.GDALSetRasterColorTable(@c_pointer, color_table_pointer)
      end
    end

    # The pixel data type for this band.
    #
    # @return [Symbol] One of FFI::GDAL::GDAL::DataType.
    def data_type
      FFI::GDAL::GDAL.GDALGetRasterDataType(@c_pointer)
    end

    # The natural block size is the block size that is most efficient for
    # accessing the format. For many formats this is simply a whole scanline
    # in which case x is set to #x_size, and y is set to 1.
    #
    # @return [Hash{x => Integer, y => Integer}]
    def block_size
      x_pointer = FFI::MemoryPointer.new(:int)
      y_pointer = FFI::MemoryPointer.new(:int)
      FFI::GDAL::GDAL.GDALGetBlockSize(@c_pointer, x_pointer, y_pointer)

      { x: x_pointer.read_int, y: y_pointer.read_int }
    end

    # @return [Array<String>]
    def category_names
      names = FFI::GDAL::GDAL.GDALGetRasterCategoryNames(@c_pointer)
      return [] if names.null?

      names.get_array_of_string(0)
    end

    # @param names [Array<String>]
    # @raise [GDAL::Error]
    def category_names=(names)
      names_pointer = GDAL._string_array_to_pointer(names)

      GDAL::CPLErrorHandler.manually_handle('Unable to set category names') do
        FFI::GDAL::GDAL.GDALSetRasterCategoryNames(@c_pointer, names_pointer)
      end
    end

    # The no data value for a band is generally a special marker value used to
    # mark pixels that are not valid data. Such pixels should generally not be
    # displayed, nor contribute to analysis operations.
    #
    # @return [Hash{value => Float, is_associated => Boolean}]
    def no_data_value
      associated = FFI::MemoryPointer.new(:bool)
      value = FFI::GDAL::GDAL.GDALGetRasterNoDataValue(@c_pointer, associated)
      value = nil if value.to_d == -10_000_000_000.0.to_d

      { value: value, is_associated: associated.read_bytes(1).to_bool }
    end

    # Sets the no data value for this band.  Do nothing if attempting to set to nil, because removing a no data value
    # is impossible until GDAL 2.1.
    #
    # @param value [Float, nil]
    # @raise [GDAL::Error]
    def no_data_value=(value)
      GDAL::CPLErrorHandler.manually_handle('Unable to set NODATA value') do
        FFI::GDAL::GDAL.GDALSetRasterNoDataValue(@c_pointer, value)
      end
    end

    # @return [Integer]
    def overview_count
      FFI::GDAL::GDAL.GDALGetOverviewCount(@c_pointer)
    end

    # @return [Boolean]
    def arbitrary_overviews?
      FFI::GDAL::GDAL.GDALHasArbitraryOverviews(@c_pointer).zero? ? false : true
    end

    # @param index [Integer] Must be between 0 and (#overview_count - 1).
    # @return [GDAL::RasterBand]
    def overview(index)
      return nil if overview_count.zero?

      overview_pointer = FFI::GDAL::GDAL.GDALGetOverview(@c_pointer, index)
      return nil if overview_pointer.null?

      self.class.new(overview_pointer)
    end

    # Returns the most reduced overview of this RasterBand that still satisfies
    # the deisred number of samples. Using 0 fetches the most reduced overview.
    # If the band doesn't have any overviews or none of the overviews have
    # enough samples, it will return the same band.
    #
    # @param desired_samples [Integer] The returned band will have at least this
    #   many pixels.
    # @return [GDAL::RasterBand] An optimal overview or the same raster band if
    #   the raster band has no overviews.
    def raster_sample_overview(desired_samples = 0)
      band_pointer = FFI::GDAL::GDAL.GDALGetRasterSampleOverview(@c_pointer, desired_samples)
      return nil if band_pointer.null?

      self.class.new(band_pointer)
    end

    # @return [GDAL::RasterBand]
    def mask_band
      band_pointer = FFI::GDAL::GDAL.GDALGetMaskBand(@c_pointer)
      return nil if band_pointer.null?

      self.class.new(band_pointer)
    end

    # @return [Array<Symbol>]
    def mask_flags
      flag_list = FFI::GDAL::GDAL.GDALGetMaskFlags(@c_pointer).to_s(2).scan(/\d/)
      flags = []

      flag_list.reverse_each.with_index do |flag, i|
        flag = flag.to_i

        if i.zero? && flag == 1
          flags << :GMF_ALL_VALID
        elsif i == 1 && flag == 1
          flags << :GMF_PER_DATASET
        elsif i == 2 && flag == 1
          flags << :GMF_ALPHA
        elsif i == 3 && flag == 1
          flags << :GMF_NODATA
        end
      end

      flags
    end

    # @param flags [Array<Symbol>, Symbol] Any of the :GMF symbols.
    # @raise [GDAL::Error]
    def create_mask_band(*flags)
      flag_value = 0

      flag_value = flags.each_with_object(flag_value) do |flag, result|
        result + case flag
                 when :GMF_ALL_VALID then 0x01
                 when :GMF_PER_DATASET then 0x02
                 when :GMF_PER_ALPHA then 0x04
                 when :GMF_NODATA then 0x08
                 else 0
                 end
      end

      GDAL::CPLErrorHandler.manually_handle('Unable to create mask band') do
        FFI::GDAL::GDAL.GDALCreateMaskBand(@c_pointer, flag_value)
      end
    end

    # Fill this band with constant value.  Useful for clearing a band and
    # setting to a default value.
    #
    # @param real_value [Float]
    # @param imaginary_value [Float]
    # @raise [GDAL::Error]
    def fill(real_value, imaginary_value = 0)
      GDAL::CPLErrorHandler.manually_handle('Unable to fill raster') do
        FFI::GDAL::GDAL.GDALFillRaster(@c_pointer, real_value, imaginary_value)
      end
    end

    # Returns minimum, maximum, mean, and standard deviation of all pixel values
    # in this band.
    #
    # @param approx_ok [Boolean] If +true+, stats may be computed based on
    #   overviews or a subset of all tiles.
    # @param force [Boolean] If +false+, stats will only be returned if the
    #   calculating can be done without rescanning the image.
    # @return [Hash{minimum: Float, maximum: Float, mean: Float,
    #   standard_deviation: Float}]
    def statistics(approx_ok: true, force: true)
      min = FFI::MemoryPointer.new(:double)
      max = FFI::MemoryPointer.new(:double)
      mean = FFI::MemoryPointer.new(:double)
      standard_deviation = FFI::MemoryPointer.new(:double)

      handler = GDAL::CPLErrorHandler.new
      handler.on_warning = proc { {} }
      handler.on_none = proc do
        {
          minimum: min.read_double,
          maximum: max.read_double,
          mean: mean.read_double,
          standard_deviation: standard_deviation.read_double
        }
      end

      handler.custom_handle do
        FFI::GDAL::GDAL.GDALGetRasterStatistics(@c_pointer,
                                                approx_ok,
                                                force,
                                                min,
                                                max,
                                                mean,
                                                standard_deviation)
      end
    end

    # @param approx_ok [Boolean] If +true+, allows for some approximating,
    #   which may speed up calculations.
    # @return [Hash{minimum => Float, maximum => Float, mean => Float,
    #   standard_deviation => Float}]
    def compute_statistics(approx_ok: false, &progress_block)
      min_ptr = FFI::MemoryPointer.new(:double)
      max_ptr = FFI::MemoryPointer.new(:double)
      mean_ptr = FFI::MemoryPointer.new(:double)
      standard_deviation_ptr = FFI::MemoryPointer.new(:double)

      GDAL::CPLErrorHandler.manually_handle('Unable to compute raster statistics') do
        FFI::GDAL::GDAL::GDALComputeRasterStatistics(
          @c_pointer,                           # hBand
          approx_ok,                            # bApproxOK
          min_ptr,                              # pdfMin
          max_ptr,                              # pdfMax
          mean_ptr,                             # pdfMean
          standard_deviation_ptr,               # pdfStdDev
          progress_block,                       # pfnProgress
          nil                                   # pProgressData
        )
      end

      {
        minimum: min_ptr.read_double,
        maximum: max_ptr.read_double,
        mean: mean_ptr.read_double,
        standard_deviation: standard_deviation_ptr.read_double
      }
    end

    # The raster value scale.  This value (in combination with the #offset
    # value) is used to transform raw pixel values into the units returned by
    # #units. For example this might be used to store elevations in GUInt16
    # bands with a precision of 0.1, and starting from -100.
    #
    # Units value = (raw value * scale) + offset
    #
    # For file formats that don't know this intrinsically a value of one is
    # returned.
    #
    # @return [Hash{value => Float, is_meaningful => Boolean}]
    def scale
      meaningful = FFI::MemoryPointer.new(:bool)
      result = FFI::GDAL::GDAL.GDALGetRasterScale(@c_pointer, meaningful)

      { value: result, is_meaningful: meaningful.read_bytes(1).to_bool }
    end

    # @param new_scale [Float]
    # @raise [GDAL::Error]
    def scale=(new_scale)
      GDAL::CPLErrorHandler.manually_handle('Unable to set raster scale') do
        FFI::GDAL::GDAL.GDALSetRasterScale(@c_pointer, new_scale.to_f)
      end
    end

    # This value (in combination with the #scale value) is used to
    # transform raw pixel values into the units returned by #units. For example
    # this might be used to store elevations in GUInt16 bands with a precision
    # of 0.1, and starting from -100.
    #
    # Units value = (raw value * scale) + offset.
    #
    # For file formats that don't know this intrinsically a value of 0.0 is
    # returned.
    #
    # @return [Hash{value => Float, is_meaningful => Boolean}]
    def offset
      meaningful = FFI::MemoryPointer.new(:bool)
      result = FFI::GDAL::GDAL.GDALGetRasterOffset(@c_pointer, meaningful)

      { value: result, is_meaningful: meaningful.read_bytes(1).to_bool }
    end

    # Sets the scaling offset. Very few formats support this method.
    #
    # @param new_offset [Float]
    # @return [Boolean]
    def offset=(new_offset)
      GDAL::CPLErrorHandler.manually_handle('Unable to set raster offset') do
        FFI::GDAL::GDAL.GDALSetRasterOffset(@c_pointer, new_offset)
      end
    end

    # @return [String]
    def unit_type
      # The returned string should not be modified, nor freed by the calling application.
      type, ptr = FFI::GDAL::GDAL.GDALGetRasterUnitType(@c_pointer)
      ptr.autorelease = false

      type
    end

    # @param new_unit_type [String] "" indicates unknown, "m" is meters, "ft"
    #   is feet; other non-standard values are allowed.
    # @raise [GDAL::Error]
    def unit_type=(new_unit_type)
      unless defined? FFI::GDAL::GDAL::GDALSetRasterUnitType
        warn "GDALSetRasterUnitType is not defined.  Can't call RasterBand#unit_type="
        return
      end

      GDAL::CPLErrorHandler.manually_handle('Unable to set unit type') do
        FFI::GDAL::GDAL.GDALSetRasterUnitType(@c_pointer, new_unit_type)
      end
    end

    # @return [GDAL::RasterAttributeTable]
    def default_raster_attribute_table
      rat_pointer = FFI::GDAL::GDAL.GDALGetDefaultRAT(@c_pointer)
      return nil if rat_pointer.null?

      GDAL::RasterAttributeTable.new(rat_pointer)
    end

    # @raise [GDAL::Error]
    def default_raster_attribute_table=(rat_table)
      rat_table_ptr = GDAL::RasterAttributeTable.new_pointer(rat_table)

      GDAL::CPLErrorHandler.manually_handle('Unable to set default raster attribute table') do
        FFI::GDAL::GDAL.GDALSetDefaultRAT(@c_pointer, rat_table_ptr)
      end
    end

    # Gets the default raster histogram.  Results are returned as a Hash so some
    # metadata about the histogram can be returned.  Example:
    #
    #   {
    #     :minimum => -0.9,
    #     :maximum => 255.9,
    #     :buckets => 256,
    #     :totals => [
    #       3954, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0,
    #       0, 0, 10, 27, 201, 699, 1766, 3472, 5013, 6464, 7698, 8352,
    #       9039, 10054, 11378, 13132, 14377, 14371, 14221, 14963, 14740,
    #       14379, 13724, 12938, 11318, 9828, 8504, 7040, 5700, 4890,
    #       4128, 3276, 2749, 2322, 1944, 1596, 1266, 1050, 784, 663,
    #       547, 518, 367, 331, 309, 279, 178, 169, 162, 149, 109, 98,
    #       90, 89, 82, 85, 74, 75, 42, 40, 39, 35, 39, 36, 36, 27, 20,
    #       12, 13, 19, 16, 12, 11, 6, 6, 8, 12, 6, 8, 11, 3, 7, 9, 2,
    #       5, 2, 5, 1, 4, 0, 0, 1, 0, 1, 2, 1, 0, 2, 1, 0, 0, 1, 0, 1,
    #       1, 1, 0, 2, 1, 2, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    #     ]
    #   }
    #
    # Also, you can pass a block to get status on the processing.  Conforms to
    # FFI::GDAL::GDAL::GDALProgressFunc.
    #
    # @param force [Boolean] Forces the computation of the histogram.  If
    #   +false+ and the default histogram isn't available, this returns nil.
    # @param block [Proc] No required, but can be used to output progress info
    #   during processing.
    #
    # @yieldparam completion [Float] The ration completed as a decimal.
    # @yieldparam message [String] Message string to display.
    #
    # @return [Hash{minimum => Float, maximum => Float, buckets => Integer,
    #   totals => Array<Integer>}] Returns +nil+ if no default histogram is
    #   available.
    def default_histogram(force: false, &block)
      min_pointer = FFI::MemoryPointer.new(:double)
      max_pointer = FFI::MemoryPointer.new(:double)
      buckets_pointer = FFI::MemoryPointer.new(:int)
      histogram_pointer = FFI::MemoryPointer.new(:pointer)
      progress_proc = block || nil

      handler = GDAL::CPLErrorHandler.new
      handler.on_warning = proc { nil }
      handler.on_none = proc do
        min = min_pointer.read_double
        max = max_pointer.read_double
        buckets = buckets_pointer.read_int

        totals = if buckets.zero?
                   []
                 else
                   histogram_pointer.get_pointer(0).read_array_of_int(buckets)
                 end

        {
          minimum: min,
          maximum: max,
          buckets: buckets,
          totals: totals
        }
      end

      handler.custom_handle do
        FFI::GDAL::GDAL.GDALGetDefaultHistogram(
          @c_pointer,
          min_pointer,
          max_pointer,
          buckets_pointer,
          histogram_pointer,
          force,
          progress_proc,
          nil
        )
      end
    end

    # Computes a histogram using the given inputs.  If you just want the default
    # histogram, use #default_histogram.
    #
    # @param min [Float] The lower bound of the histogram.
    # @param max [Float] The upper bound of the histogram.
    # @param buckets [Integer]
    # @param include_out_of_range [Boolean] If +true+, values below the
    #   histogram range will be mapped into the first bucket of the output
    #   data; values above the range will be mapped into the last bucket. If
    #   +false+, values outside of the range will be discarded.
    # @param approx_ok [Boolean]
    # @param block [Proc] No required, but can be used to output progress info
    #   during processing.
    #
    # @yieldparam completion [Float] The ration completed as a decimal.
    # @yieldparam message [String] Message string to display.
    #
    # @return [Hash{minimum => Float, maximum => Float, buckets => Integer,
    #   totals => Array<Integer>}]
    #
    # @see #default_histogram for more info.
    def histogram(min, max, buckets, include_out_of_range: false,
      approx_ok: false, &block)
      histogram_pointer = FFI::MemoryPointer.new(:pointer, buckets)
      progress_proc = block || nil

      handler = GDAL::CPLErrorHandler.new
      handler.on_warning = proc { nil }
      handler.on_none = proc do
        totals = if buckets.zero?
                   []
                 else
                   histogram_pointer.read_array_of_int(buckets)
                 end

        {
          minimum: min,
          maximum: max,
          buckets: buckets,
          totals: totals
        }
      end

      handler.custom_handle do
        FFI::GDAL::GDAL.GDALGetRasterHistogram(@c_pointer,
                                               min.to_f,
                                               max.to_f,
                                               buckets,
                                               histogram_pointer,
                                               include_out_of_range,
                                               approx_ok,
                                               progress_proc,
                                               nil)
      end
    end

    # Copies the contents of one raster to another similarly configure band.
    # The two bands must have the same width and height but do not have to be
    # the same data type.
    #
    # Options:
    #   * :compressed
    #     * 'YES': forces alignment on the destination_band to achieve the best
    #       compression.
    #
    # @param destination_band [GDAL::RasterBand]
    # @param options [Hash]
    # @option options compress [String] Only 'YES' is supported.
    # @return [Boolean]
    def copy_whole_raster(destination_band, **options, &progress)
      destination_pointer = GDAL._pointer(GDAL::RasterBand, destination_band)
      options_ptr = GDAL::Options.pointer(options)

      GDAL::CPLErrorHandler.manually_handle('Unable to copy whole raster') do
        FFI::GDAL::GDAL.GDALRasterBandCopyWholeRaster(@c_pointer,
                                                      destination_pointer,
                                                      options_ptr,
                                                      progress,
                                                      nil)
      end
    end

    # IO access for raster data in this band. Default values are set up to
    # operate on one line at a time, keeping the same aspect ratio.
    #
    # On buffers... You can use different size buffers from the original x and
    # y size to allow for resampling. Using larger buffers will upsample the
    # raster data; smaller buffers will downsample it.
    #
    # On +pixel_space+ and +line_space+.... These values control how data is
    # organized in the buffer.
    #
    # @param access_flag [Symbol] Must be 'r' or 'w'.
    # @param buffer [FFI::MemoryPointer] Allows for passing in your own buffer,
    #   which is really only useful when writing.
    # @param x_size [Integer] The number of pixels per line to operate on.
    #   Defaults to the value of {{#x_size}}.
    # @param y_size [Integer] The number of lines to operate on. Defaults to the
    #   value of {{#y_size}}.
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
    #   +buffer_y_size+. Defaults to {{#data_type}}.
    # @param pixel_space [Integer] The byte offset from the start of one pixel
    #   value in the buffer to the start of the next pixel value within a line.
    #   If defaulted (0), the size of +buffer_data_type+ is used.
    # @param line_space [Integer] The byte offset from the start of one line in
    #   the buffer to the start of the next. If defaulted (0), the size of
    #   +buffer_data_type+ * +buffer_x_size* is used.
    # @return [FFI::MemoryPointer] Pointer to the data that was read/written.
    # rubocop:disable Metrics/ParameterLists
    def raster_io(access_flag, buffer = nil,
      x_size: nil, y_size: nil, x_offset: 0, y_offset: 0,
      buffer_x_size: nil, buffer_y_size: nil, buffer_data_type: data_type,
      pixel_space: 0, line_space: 0)
      return unless @c_pointer

      x_size ||= self.x_size
      y_size ||= self.y_size

      buffer_x_size ||= x_size
      buffer_y_size ||= y_size
      buffer ||= GDAL._pointer_from_data_type(buffer_data_type, buffer_x_size * buffer_y_size)

      FFI::GDAL::GDAL.GDALRasterIO(
        @c_pointer,
        GDAL._gdal_access_flag(access_flag),
        x_offset,
        y_offset,
        x_size,
        y_size,
        buffer,
        buffer_x_size,
        buffer_y_size,
        buffer_data_type,
        pixel_space,
        line_space
      )

      buffer
    end
    # rubocop:enable Metrics/ParameterLists

    # Read a block of image data, more efficiently than #read.  Doesn't
    # resample or do data type conversion.
    #
    # @param x_block_number [Integer] The horizontal block offset, with 0 indicating
    #   the left-most block, 1 the next block, etc.
    # @param y_block_number [Integer] The vertical block offset, with 0 indicating the
    #   top-most block, 1 the next block, etc.
    # @param image_buffer [FFI::Pointer] Optional pointer to use for reading
    #   the data into. If not provided, one will be created and returned.
    # @return [FFI::MemoryPointer] The image buffer that contains the read data.
    #   If you passed in +image_buffer+ you don't need to bother with this
    #   return value since that original buffer will contain the data.
    def read_block(x_block_number, y_block_number, image_buffer = nil)
      image_buffer ||= FFI::MemoryPointer.new(:buffer_out, block_buffer_size)

      GDAL::CPLErrorHandler.manually_handle('Unable to read block') do
        FFI::GDAL::GDAL.GDALReadBlock(@c_pointer, x_block_number, y_block_number, image_buffer)
      end

      image_buffer
    end

    # @param x_block_number [Integer] The horizontal block offset, with 0 indicating
    #   the left-most block, 1 the next block, etc.
    # @param y_block_number [Integer] The vertical block offset, with 0 indicating the
    #   top-most block, 1 the next block, etc.
    # @param data_pointer [FFI::Pointer] Optional pointer to write the data to.
    #   If not provided, one will be created and returned.
    def write_block(x_block_number, y_block_number, data_pointer = nil)
      data_pointer ||= FFI::Buffer.alloc_inout(block_buffer_size)

      GDAL::CPLErrorHandler.manually_handle('Unable to write block') do
        FFI::GDAL::GDAL.GDALWriteBlock(@c_pointer, x_block_number, y_block_number, data_pointer)
      end

      data_pointer
    end

    # The minimum and maximum values for this band.
    #
    # @return [Hash{min => Float, max => Float}]
    def min_max(approx_ok: false)
      min_max = FFI::MemoryPointer.new(:double, 2)
      FFI::GDAL::GDAL.GDALComputeRasterMinMax(@c_pointer, approx_ok, min_max)

      { min: min_max[0].read_double, max: min_max[1].read_double }
    end

    # The minimum value in the band, not counting NODATA values. For file
    # formats that don't know this intrinsically, the minimum supported value
    # for the data type will generally be returned.
    #
    # @return [Hash{value => Float, is_tight => Boolean}] The +is_tight+ value
    #   tells whether the minimum is a tight minimum.
    def minimum_value
      is_tight = FFI::MemoryPointer.new(:bool)
      value = FFI::GDAL::GDAL.GDALGetRasterMinimum(@c_pointer, is_tight)

      { value: value, is_tight: is_tight.read_bytes(1).to_bool }
    end

    # The maximum value in the band, not counting NODATA values. For file
    # formats that don't know this intrinsically, the maximum supported value
    # for the data type will generally be returned.
    #
    # @return [Hash{value => Float, is_tight => Boolean}] The +is_tight+ value
    #   tells whether the maximum is a tight maximum.
    def maximum_value
      is_tight = FFI::MemoryPointer.new(:bool)
      value = FFI::GDAL::GDAL.GDALGetRasterMaximum(@c_pointer, is_tight)

      { value: value, is_tight: is_tight.read_bytes(1).to_bool }
    end

    private

    # @return [GDAL::Dataset, nil]
    def init_dataset
      dataset_ptr = FFI::GDAL::GDAL.GDALGetBandDataset(@c_pointer)
      return nil if dataset_ptr.null?

      GDAL::Dataset.new(dataset_ptr, access_flag, shared_open: true)
    end
  end
end
