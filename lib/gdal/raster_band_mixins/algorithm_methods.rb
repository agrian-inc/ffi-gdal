# typed: false
# frozen_string_literal: true

module GDAL
  module RasterBandMixins
    module AlgorithmMethods
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Compute the optimal PCT for RGB image. Implements a median cut
        # algorithm to compute an "optimal" pseudo-color table for representing
        # an input RGB image. This PCT could then be used with
        # +dither_rgb_to_pct+ to convert a 24-bit RGB image into an 8-bit
        # pseudo-colored image.
        #
        # @param red_band [GDAL::RasterBand, FFI::Pointer]
        # @param green_band [GDAL::RasterBand, FFI::Pointer]
        # @param blue_band [GDAL::RasterBand, FFI::Pointer]
        # @param colors [Integer] Number of colors to return; 2-256.
        # @param color_interpretation [FFI::GDAL::GDAL::PaletteInterp] The type
        #   of ColorTable to return.
        # @param progress_function [Proc, FFI:GDAL::GDAL.ProgressFunc]
        # @param progress_arg [FFI::Pointer] Usually used when when using a
        #   +FFI::CPL::Progress.GDALCreateScaledProgress+.
        # @return [GDAL::ColorTable]
        def compute_median_cut_pct(red_band, green_band, blue_band,
          colors, color_interpretation, progress_function: nil, progress_arg: nil)
          color_table = GDAL::ColorTable.new(color_interpretation)

          FFI::GDAL::Alg.GDALComputeMedianCutPCT(
            red_band,
            green_band,
            blue_band,
            nil, # This isn't yet supported in GDAL.
            colors,
            color_table.c_pointer,
            progress_function,
            progress_arg
          )

          color_table
        end

        # 24-bit to 8-bit conversion with dithering.  Utilizes Floyd-Steinberg
        # dithering, using the provided color table.
        #
        # The red, green, and blue input bands do not necessarily need to come
        # from the same file, but they must be the same width and height. They
        # will be clipped to 8-bit during reading, so non-eight bit bands are
        # generally inappropriate. Likewise, +output_band+ will be written with
        # 8-bit values and must match the width and height of the source bands.
        #
        # The ColorTable cannot have more than 256 entries.
        #
        # @param red_band [GDAL::RasterBand, FFI::Pointer]
        # @param green_band [GDAL::RasterBand, FFI::Pointer]
        # @param blue_band [GDAL::RasterBand, FFI::Pointer]
        # @param output_band [GDAL::RasterBand, FFI::Pointer]
        # @param color_table [GDAL::ColorTable, FFI::Pointer]
        # @param progress_function [Proc, FFI:GDAL::GDAL.ProgressFunc]
        # @param progress_arg [FFI::Pointer] Usually used when when using a
        #   +FFI::CPL::Progress.GDALCreateScaledProgress+.
        # @return [GDAL::RasterBand] +output_band+ with the dithering algorithm
        #   applied.
        def dither_rgb_to_pct(red_band, green_band, blue_band, output_band,
          color_table, progress_function: nil, progress_arg: nil)
          red_ptr = GDAL._pointer(GDAL::RasterBand, red_band)
          green_ptr = GDAL._pointer(GDAL::RasterBand, green_band)
          blue_ptr = GDAL._pointer(GDAL::RasterBand, blue_band)
          output_ptr = GDAL._pointer(GDAL::RasterBand, output_band)
          color_table_ptr = GDAL._pointer(GDAL::ColorTable, color_table)

          FFI::GDAL::Alg.GDALDitherRGB2PCT(
            red_ptr,
            green_ptr,
            blue_ptr,
            output_ptr,
            color_table_ptr,
            progress_function,
            progress_arg
          )

          output_band
        end
      end

      # Computes a 16-bit (0-65535) checksum from a region of raster data.
      # Floating point data is converted to 32-bit integers so decimal portions
      # of the raster data won't affect the checksum.  Real and imaginary
      # components of complex bands influence the result.
      #
      # @param x_offset [Integer]
      # @param y_offset [Integer]
      # @param x_size [Integer]
      # @param y_size [Integer]
      # @return [Integer] The checksum value.
      def checksum_image(x_offset, y_offset, x_size, y_size)
        !!FFI::GDAL::Alg.GDALChecksumImage(
          @c_pointer,
          x_offset,
          y_offset,
          x_size,
          y_size
        )
      end

      # Computes the proximity of all pixels in the proximity_band to those in
      # this band. By default all non-zero pixels in this band will be
      # considered as "target", and all proximities will be computed in pixels.
      # Target pixels are set to the value corresponding to a distance of zero.
      #
      # Note that this modifies the source band in place with the computed
      # values.
      #
      # @param proximity_band [GDAL::RasterBand, FFI::Pointer]
      # @param progress_function [Proc, FFI:GDAL::GDAL.ProgressFunc]
      # @param progress_arg [FFI::Pointer] Usually used when when using a
      #   +FFI::CPL::Progress.GDALCreateScaledProgress+.
      # @param options [Hash]
      # @option options [String] values A list of target pixel values to measure
      #   the distance from. If this isn't provided, proximity will be computed
      #   from non-zero pixel values.
      # @option options [String] distunits (PIXEL) Indicates what unit type to
      #   use for computing.
      # @option options [Integer] maxdist The maximum distance to search.
      # @option options [Integer] nodata If not given, it will try to use the
      #   nodata value on the +proximity_band+. If not found there, will use
      #   65535.
      # @option options [Integer] fixed_buf_val If set, all pixels within the
      #   +maxdist+ threshold are set to this fixed value instead of to a
      #   proximity distance.
      def compute_proximity!(proximity_band, progress_function: nil, progress_arg: nil, **options)
        proximity_band_ptr = GDAL._pointer(GDAL::RasterBand, proximity_band)
        options_ptr = GDAL::Options.pointer(options)

        FFI::GDAL::Alg.GDALComputeProximity(
          @c_pointer,
          proximity_band_ptr,
          options_ptr,
          progress_function,
          progress_arg
        )
      end

      # Fill selected raster regions by interpolation from the edges. It
      # interpolates values for all designated nodata pixels (marked by zeroes
      # in +mask_band+). For each pixel, a four-direction conic search is done
      # to find values to interpolate from (using inverse distance weighting).
      # Once all values are interpolated, zero or more smoothing iterations
      # (3x3 average filters on interpolated pixels) are applied to smooth out
      # artifacts.
      #
      # This is generally suitable for interpolating missing regions of fairly
      # continuously varying rasters (such as elevation models, for instance).
      # It is also suitable for filling small holes and cracks in more
      # irregularly varying images (like aerial photos). Its is generally not so
      # great for interpolating a raster from sparse point data. See GDAL::Grid
      # for that case.
      #
      # Note that this alters values of the current raster band.
      #
      # @param mask_band [GDAL::RasterBand] Band that indicates which pixels to
      #   be interpolated (it does so using 0-valued pixels).
      # @param max_search_distance [Float] Max number of pixels to search in all
      #   directions to find values to interpolate from.
      # @param smoothing_iterations [Integer] The number of 3x3 smoothing filter
      #   passes to run.  Can be 0.
      # @param progress_function [Proc, FFI:GDAL::GDAL.ProgressFunc]
      # @param progress_arg [FFI::Pointer] Usually used when when using a
      #   +FFI::CPL::Progress.GDALCreateScaledProgress+.
      # @param options [Hash]
      # TODO: document what valid options are.
      def fill_nodata!(mask_band, max_search_distance, smoothing_iterations, progress_function: nil, progress_arg: nil,
        **options)
        mask_band_ptr = GDAL._pointer(GDAL::RasterBand, mask_band)
        options_ptr = GDAL::Options.pointer(options)

        !!FFI::GDAL::Alg.GDALFillNodata(@c_pointer,
                                        mask_band_ptr,
                                        max_search_distance,
                                        0, # deprecated option in GDAL
                                        smoothing_iterations,
                                        options_ptr,
                                        progress_function,
                                        progress_arg)
      end

      # Creates vector polygons for all connected regions of pixels in the raster
      # that share a common pixel value. Optionally, each polygon may be
      # labeled with the pixel value in an attribute. Optionally, a mask band
      # can be provided to determine which pixels are eligible for processing.
      #
      # The C API implements two functions for this: +GDALPolygonize+ and
      # +GDALFPolygonize+, where the former uses a 32-bit Integer buffer and the
      # latter uses a 32-bit Float buffer. The Integer version may be quicker,
      # but the Float version more accurate. As such, calling +polygonize+
      # defaults to use the Float version internally, but you can tell it to use
      # the Integer version by using the +use_integer_function+ flag.
      #
      # Polygon features will be created on +layer+ with Polygon geometries
      # representing the polygons. The geometries will be in the georeferenced
      # coordinate system of the image (based on the GeoTransform) of the source
      # Dataset). It is acceptable for +layer+ to already have other features.
      #
      # Note that this does not set the coordinate system on the output
      # layer--the application is responsible for doing so.
      #
      # @param layer [OGR::Layer, FFI::Pointer] The layer to write the polygons
      #   to.
      # @param mask_band [GDAL::RasterBand, FFI::Pointer] Optional band, where all
      #   pixels in the mask with a value other than zero will be considered
      #   suitable for collection as polygons.
      # @param pixel_value_field [Integer] Index of the feature attribute into
      #   which the pixel value of the polygon should be written.
      # @param use_integer_function [Boolean] Indicates using GDAL's
      #   GDALPolygonize() instead of GDALFPolygonize(); the former uses a
      #   32-bit integer buffer for reading pixel band values, the latter uses a
      #   32-bit float buffer. The integer based function is faster but less
      #   precise.
      # @param options [Hash]
      # @option options [Integer] '8CONNECTED' (4) Set to 8 to use 8
      #   connectedness.
      # @param progress_function [Proc, FFI:GDAL::GDAL.ProgressFunc]
      # @param progress_arg [FFI::Pointer] Usually used when when using a
      #   +FFI::CPL::Progress.GDALCreateScaledProgress+.
      # @return [OGR::Layer]
      def polygonize(layer, mask_band: nil, pixel_value_field: -1, use_integer_function: false, progress_function: nil,
        progress_arg: nil, **options)
        mask_band_ptr = GDAL._pointer(GDAL::RasterBand, mask_band, warn_on_nil: false)
        layer_ptr = GDAL._pointer(OGR::Layer, layer)
        raise OGR::InvalidLayer, "Invalid layer: #{layer.inspect}" if layer_ptr.null?

        log "Pixel value field: #{pixel_value_field}"

        options_ptr = GDAL::Options.pointer(options)

        function = use_integer_function ? :GDALPolygonize : :GDALFPolygonize

        FFI::GDAL::Alg.send(
          function,
          @c_pointer,             # hSrcBand
          mask_band_ptr,          # hMaskBand
          layer_ptr,              # hOutLayer
          pixel_value_field,      # iPixValField
          options_ptr,            # papszOptions
          progress_function,      # pfnProgress
          progress_arg            # pProgressArg
        )

        layer_ptr.instance_of?(OGR::Layer) ? layer_ptr : OGR::Layer.new(layer_ptr)
      end

      # Removes raster polygons that are smaller than the given threshold (in
      # pixels) and replaces them with the pixel value of the largest neighbor
      # polygon. Polygons are determined as regions of the raster where the
      # pixels all have the same value, and that are contiguous (connected).
      #
      # If +mask_band+ is given, "nodata" pixels in the band will not be treated
      # as part of a polygon, regardless of their pixel values.
      #
      # @param size_threshold [Integer] Polygons found in the raster with sizes
      #   smaller than this will be merged into their largest neighbor.
      # @param connectedness [Integer] 4 or 8. 4 indicates that diagonal pixels
      #   are not considered directly adjacent for polygon membership purposes;
      #   8 indicates they are.
      # @param mask_band [GDAL::RasterBand] [description] All pixels in this
      #   band with a value other than 0 will be considered suitable for
      #   inclusion in polygons.
      # @param progress_function [Proc, FFI:GDAL::GDAL.ProgressFunc]
      # @param progress_arg [FFI::Pointer] Usually used when when using a
      #   +FFI::CPL::Progress.GDALCreateScaledProgress+.
      # @param options [Hash] None supported in GDAL as of this writing.
      def sieve_filter!(size_threshold, connectedness, mask_band: nil, progress_function: nil, progress_arg: nil,
        **options)
        _sieve_filter(size_threshold, connectedness, self, mask_band: mask_band,
                                                           progress_function: progress_function,
                                                           progress_arg: progress_arg,
                                                           **options)
      end

      # The same as +sieve_filter!+, but returns a new GDAL::RasterBand as the
      # result.
      #
      # @see +sieve_filter!
      # @param destination_band [GDAL::RasterBand]
      def sieve_filter(size_threshold, connectedness, destination_band, mask_band: nil, progress_function: nil,
        progress_arg: nil, **options)
        _sieve_filter(size_threshold, connectedness, destination_band, mask_band: mask_band,
                                                                       progress_function: progress_function,
                                                                       progress_arg: progress_arg,
                                                                       **options)

        if destination_band.is_a? GDAL::RasterBand
          destination_band
        else
          GDAL::RasterBand.new(destination_band)
        end
      end

      private

      # @param size_threshold [Integer] Polygons found in the raster with sizes
      #   smaller than this will be merged into their largest neighbor.
      # @param connectedness [Integer] 4 or 8. 4 indicates that diagonal pixels
      #   are not considered directly adjacent for polygon membership purposes;
      #   8 indicates they are.
      # @param mask_band [GDAL::RasterBand] [description] All pixels in this
      #   band with a value other than 0 will be considered suitable for
      #   inclusion in polygons.
      # @param progress_function [Proc, FFI:GDAL::GDAL.ProgressFunc]
      # @param progress_arg [FFI::Pointer] Usually used when when using a
      #   +FFI::CPL::Progress.GDALCreateScaledProgress+.
      # @param options [Hash] None supported in GDAL as of this writing.
      def _sieve_filter(size_threshold, connectedness, destination_band, mask_band: nil, progress_function: nil,
        progress_arg: nil, **options)
        mask_band_ptr = GDAL._pointer(GDAL::RasterBand, mask_band, warn_on_nil: false)
        destination_band_ptr = GDAL._pointer(GDAL::RasterBand, destination_band)

        if destination_band.nil? || destination_band.null?
          raise GDAL::InvalidRasterBand, "destination_band isn't a valid GDAL::RasterBand: #{destination_band}"
        end

        options_ptr = GDAL::Options.pointer(options)

        FFI::GDAL::Alg.GDALSieveFilter(
          @c_pointer,
          mask_band_ptr,
          destination_band_ptr,
          size_threshold,
          connectedness,
          options_ptr,
          progress_function,
          progress_arg
        )
      end
    end
  end
end
