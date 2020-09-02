# typed: false
# frozen_string_literal: true

module GDAL
  module DatasetMixins
    # Wrappers for Warp algorithm methods defined in gdal_alg.h.
    module AlgorithmMethods
      # Rasterizes the geometric objects +geometries+ into this raster dataset.
      # +transformer+ can be nil as long as the +geometries+ are within the
      # georeferenced coordinates of this raster's dataset.
      #
      # @param band_numbers [Array<Integer>, Integer]
      # @param geometries [Array<OGR::Geometry>, OGR::Geometry]
      # @param burn_values [Array<Float>, Float]
      # @param transformer [Proc]
      # @param options [Hash]
      # @option options all_touched [Boolean]  If +true+, sets all pixels touched
      #   by the line or polygons, not just those whose center is within the
      #   polygon or that are selected by Brezenham's line algorithm.  Defaults to
      #   +false+.
      # @option options burn_value_from ["Z"] Use the Z values of the geometries.
      # @option options merge_alg [String] "REPLACE" or "ADD".  REPLACE results
      #   in overwriting of value, while ADD adds the new value to the existing
      #   raster, suitable for heatmaps for instance.
      def rasterize_geometries!(band_numbers, geometries, burn_values,
        transformer: nil, transform_arg: nil, **options, &progress_block)

        if geo_transform.nil? && gcp_count.zero?
          raise "Can't rasterize geometries--no geo_transform or GCPs have been defined on the dataset."
        end

        gdal_options = GDAL::Options.pointer(options)
        band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]
        geometries = geometries.is_a?(Array) ? geometries : [geometries]
        burn_values = burn_values.is_a?(Array) ? burn_values : [burn_values]

        band_numbers_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.size)
        band_numbers_ptr.write_array_of_int(band_numbers)

        geometries_ptr = FFI::MemoryPointer.new(:pointer, geometries.size)
        geometries_ptr.write_array_of_pointer(geometries.map(&:c_pointer))

        burn_values_ptr = FFI::MemoryPointer.new(:pointer, burn_values.size)
        burn_values_ptr.write_array_of_double(burn_values)

        FFI::GDAL::Alg.GDALRasterizeGeometries(@c_pointer,
                                               band_numbers.size,
                                               band_numbers_ptr,
                                               geometries.size,
                                               geometries_ptr,
                                               transformer,
                                               transform_arg,
                                               burn_values_ptr,
                                               gdal_options,
                                               progress_block,
                                               nil)
      end

      # @param band_numbers [Array<Integer>, Integer]
      # @param layers [Array<OGR::Layer>, OGR::Layer]
      # @param burn_values [Array<Float>, Float]
      # @param transformer [Proc]
      # @param options [Hash]
      # @option options attribute [String] An attribute field on features to be
      #   used for a burn-in value, which will be burned into all output bands.
      # @option options chunkysize [Integer] The height in lines of the chunk to
      #   operate on.
      # @option options all_touched [Boolean]  If +true+, sets all pixels touched
      #   by the line or polygons, not just those whose center is within the
      #   polygon or that are selected by Brezenham's line algorithm.  Defaults to
      #   +false+.
      # @option options burn_value_from ["Z"] Use the Z values of the geometries.
      # @option @options merge_alg [String] "REPLACE" or "ADD".  REPLACE results
      #   in overwriting of value, while ADD adds the new value to the existing
      #   raster, suitable for heatmaps for instance.
      def rasterize_layers!(band_numbers, layers, burn_values,
        transformer: nil, transform_arg: nil, **options, &progress_block)
        gdal_options = GDAL::Options.pointer(options)
        band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]
        log "band numbers: #{band_numbers}"

        layers = layers.is_a?(Array) ? layers : [layers]
        log "layers: #{layers}"

        burn_values = burn_values.is_a?(Array) ? burn_values : [burn_values]
        log "burn values: #{burn_values}"

        band_numbers_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.size)
        band_numbers_ptr.write_array_of_int(band_numbers)
        log "band numbers ptr null? #{band_numbers_ptr.null?}"

        layers_ptr = FFI::MemoryPointer.new(:pointer, layers.size)
        layers_ptr.write_array_of_pointer(layers.map(&:c_pointer))
        log "layers ptr null? #{layers_ptr.null?}"

        burn_values_ptr = FFI::MemoryPointer.new(:pointer, burn_values.size)
        burn_values_ptr.write_array_of_double(burn_values)
        log "burn value ptr null? #{burn_values_ptr.null?}"

        FFI::GDAL::Alg.GDALRasterizeLayers(@c_pointer, # hDS
                                           band_numbers.size,                                # nBandCount
                                           band_numbers_ptr,                                 # panBandList
                                           layers.size,                                      # nLayerCount
                                           layers_ptr,                                       # pahLayers
                                           transformer,                                      # pfnTransformer
                                           transform_arg,                                    # pTransformerArg
                                           burn_values_ptr,                                  # padfLayerBurnValues
                                           gdal_options,                                     # papszOptions
                                           progress_block,                                   # pfnProgress
                                           nil)                                              # pProgressArg
      end

      # @param destination_dataset [String]
      # @param transformer [Proc, FFI::Function]
      # @param transformer_arg_ptr [FFI::Pointer] The pointer created from one
      #   of the GDAL::Transformers.
      # @param warp_options [Hash]
      # @option warp_options [String] init Indicates that the output dataset should be
      #   initialized to the given value in any area where valid data isn't
      #   written.  In form: "v[,v...]"
      # @param band_numbers [Integer, Array<Integer>] Raster bands to include in the
      #   warping.  0 indicates all bands.
      # @param progress [Proc]
      # @return [GDAL::Dataset, nil] The new dataset or nil if the warping failed.
      def simple_image_warp(destination_dataset, transformer, transformer_arg_ptr,
        warp_options, band_numbers = 0, progress = nil)
        destination_dataset_ptr = destination_dataset.c_pointer

        band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]
        log "band numbers: #{band_numbers}"

        bands_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.size)
        bands_ptr.write_array_of_int(band_numbers)
        log "band numbers ptr null? #{bands_ptr.null?}"

        success = FFI::GDAL::Alg.GDALSimpleImageWarp(@c_pointer,
                                                     destination_dataset_ptr,
                                                     band_numbers.size,
                                                     bands_ptr,
                                                     transformer,
                                                     transformer_arg_ptr,
                                                     progress,
                                                     nil,
                                                     warp_options.c_pointer)

        success ? destination_dataset : nil
      end

      # @param transformer [GDAL::Transformers]
      # @return [Hash{geo_transform: GDAL::GeoTransform, lines: Integer, pixels: Integer}]
      def suggested_warp_output(transformer)
        geo_transform = GDAL::GeoTransform.new
        pixels_ptr = FFI::MemoryPointer.new(:int)
        lines_ptr = FFI::MemoryPointer.new(:int)

        FFI::GDAL::Alg.GDALSuggestedWarpOutput(
          @c_pointer,
          transformer.function,
          transformer.c_pointer,
          geo_transform.c_pointer,
          pixels_ptr,
          lines_ptr
        )

        {
          geo_transform: geo_transform,
          lines: lines_ptr.read_int,
          pixels: pixels_ptr.read_int
        }
      end

      # @param transformer [GDAL::Transformers]
      # @return [Hash{extents: Hash{ min_x: Integer, min_y: Integer, max_x: Integer,
      #   max_y: Integer }, geo_transform: GDAL::GeoTransform, lines: Integer,
      #   pixels: Integer}]
      def suggested_warp_output2(transformer)
        geo_transform = GDAL::GeoTransform.new
        pixels_ptr = FFI::MemoryPointer.new(:int)
        lines_ptr = FFI::MemoryPointer.new(:int)
        extents_ptr = FFI::MemoryPointer.new(:double, 4)
        options = 0 # C code says this isn't used yet.

        FFI::GDAL::Alg.GDALSuggestedWarpOutput2(
          @c_pointer,
          transformer.function,
          transformer.c_pointer,
          geo_transform.c_pointer,
          pixels_ptr,
          lines_ptr,
          extents_ptr,
          options
        )

        extents_array = extents_ptr.read_array_of_double(4)

        extents = {
          min_x: extents_array[0],
          min_y: extents_array[1],
          max_x: extents_array[2],
          max_y: extents_array[3]
        }

        {
          extents: extents,
          geo_transform: geo_transform,
          lines: lines_ptr.read_int,
          pixels: pixels_ptr.read_int
        }
      end
    end
  end
end
