# typed: false
# frozen_string_literal: true

require 'bundler/setup'
require 'ffi-gdal'
require 'gdal/dataset'
require 'gdal/warp_operation'
require 'gdal/warp_options'
require 'gdal/transformers/general_image_projection_transformer'
require 'gdal/transformers/general_image_projection_transformer2'
require 'byebug'

GDAL::Logger.logging_enabled = true

module Examples
  module Warping
    class << self
      def make_basic_options(source_dataset, dest_dataset)
        options = GDAL::WarpOptions.new
        options.source_dataset = source_dataset
        options.destination_dataset = dest_dataset
        options.source_bands = [1]
        options.band_count = 1
        options.destination_bands = [1]
        options.progress_formatter = GDAL.simple_progress_formatter

        options
      end

      def make_general_reprojection_options(source_dataset, dest_dataset)
        options = make_basic_options(source_dataset, dest_dataset)

        # Reprojection Transformer
        transformer_arg = GDAL::Transformers::GeneralImageProjectionTransformer.new(
          source_dataset, destination_dataset: dest_dataset, order: 0
        )
        options.transformer_arg = transformer_arg

        options
      end

      def make_clipped_options(source_dataset, dest_dataset, clip_wkt)
        options = make_basic_options(source_dataset, dest_dataset)

        geom = OGR::Geometry.create_from_wkt(clip_wkt)
        spatial_reference = OGR::SpatialReference.new_from_epsg(source_dataset.spatial_reference.authority_code.to_i)
        geom.spatial_reference = spatial_reference
        options.cutline_geometry = geom
        # options.cutline_blend_distance = 100
        options.resample_algorithm = :GRA_Average

        options.warp_operation_options = {
          init_dest: 'NO_DATA',
          cutline: clip_wkt
          # cutline_all_touched: 'TRUE'
          # cutline_all_touched: true
        }

        transformer_arg = GDAL::Transformers::GeneralImageProjectionTransformer2.new(
          source_dataset, destination_dataset: dest_dataset,
                          insert_center_long: 'FALSE'
          # DST_SRS: spatial_reference.to_wkt
        )
        # transformer_arg = GDAL::Transformers::GeneralImageProjectionTransformer.new(
        #   source_dataset, destination_dataset: dest_dataset,
        #   # source_wkt: source_dataset.projection, destination_wkt: dest_dataset.projection,
        #   gcp_use_ok: true, order: 0
        # )

        options.transformer_arg = transformer_arg
        # options.transformer = cutline_transformer
        # options.resample_algorithm = :GRA_CubicSpline

        no_data_value = source_dataset.raster_band(1).no_data_value[:value]
        puts "source no data value: #{no_data_value}"
        # options.source_no_data_real = [no_data_value]
        # options.source_no_data_imaginary = [no_data_value]
        # options.destination_no_data_real = [no_data_value]
        # options.destination_no_data_imaginary = [no_data_value]

        options
      end

      def copy_dataset(source_dataset, dest_path)
        driver = source_dataset.driver

        driver.copy_dataset(source_dataset, dest_path)
      end

      def create_destination_reprojected_dataset(source_dataset, path, srid)
        dest_wkt = OGR::SpatialReference.new_from_epsg(srid).to_wkt

        transformer_arg = GDAL::Transformers::GeneralImageProjectionTransformer.new(
          source_dataset, destination_wkt: dest_wkt, order: 1
        )

        suggested_options = source_dataset.suggested_warp_output(transformer_arg)

        driver = GDAL::Driver.by_name 'GTiff'
        ds = driver.create_dataset(path, suggested_options[:pixels], suggested_options[:lines],
                                   data_type: source_dataset.raster_band(1).data_type)
        ds.geo_transform = suggested_options[:geo_transform]
        ds.projection = dest_wkt
        ds.raster_band(1).no_data_value = source_dataset.raster_band(1).no_data_value[:value]

        ds
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  args = ARGV.dup
  raise 'Must only supply 2 args: [source destination]' unless args.length == 2

  # 32616
  # harper_wkt = <<-WKT
  # POLYGON ((446272.16070421785116196 3450423.99460560129955411, 446267.51794699463061988 3450225.33339292788878083,
  # 446169.27478282485390082 3450181.28046096721664071, 446167.92126038181595504 3449679.13779170718044043,
  # 446257.50292950111906976 3449447.46736949309706688, 446177.33125468820799142 3449388.86781942518427968,
  # 446181.49593684601131827 3449256.37749340012669563, 446201.94002113211899996 3449230.98345079040154815,
  # 446963.20628352143103257 3449239.17042332561686635, 446960.24312665761681274 3449612.50297579308971763,
  # 446866.33160242711892352 3449708.10946208890527487, 446750.25655526417540386 3449727.9624758935533464,
  # 446691.84310374449705705 3449902.8676586695946753, 446610.46438609907636419 3450082.70331544848158956,
  # 446642.15819176007062197 3450128.30150367366150022, 446528.87474136805394664 3450220.39211917016655207,
  # 446272.16070421785116196 3450423.99460560129955411))
  # WKT

  # 4326
  chualar_wkt = <<-WKT
    Polygon ((-121.52653414366494644 36.58183382122394534, -121.52612663439269625 36.57798512254166923,
    -121.52503994300006696 36.57793984373364538, -121.52503994300006696 36.57952460201457967,
    -121.5239985304154402 36.57952460201457967, -121.52404380922347116 36.57789456492562152,
    -121.52245905094252976 36.57789456492562152, -121.52264016617463938 36.58151686956775706,
    -121.52413436683951886 36.58165270599183572, -121.52422492445558078 36.58002266890287757,
    -121.52513050061611466 36.58002266890287757, -121.52653414366494644 36.58183382122394534))
  WKT

  source_path = args.shift
  dest_path = args.shift

  source_dataset = GDAL::Dataset.open(source_path, 'r')
  puts "source srid: #{source_dataset.spatial_reference.authority_code.to_i}"

  dest_dataset = Examples::Warping
                 .create_destination_reprojected_dataset(source_dataset, dest_path,
                                                         source_dataset.spatial_reference.authority_code.to_i)
  # Examples::Warping.copy_dataset(source_dataset, dest_path)
  # dest_dataset = GDAL::Dataset.open(dest_path, 'w')

  options = Examples::Warping.make_clipped_options(source_dataset, dest_dataset, chualar_wkt)
  warp_operation = GDAL::WarpOperation.new(options)
  puts "output raster size: #{dest_dataset.raster_x_size}, #{dest_dataset.raster_y_size}"
  warp_operation.chunk_and_warp_image(0, 0, dest_dataset.raster_x_size, dest_dataset.raster_y_size)
  # source_dataset.simple_image_warp(dest_dataset, options.transformer, options.transformer_arg,
  # band_numbers = [1], options)

  source_dataset.close
  dest_dataset.close
end
