# typed: true
# frozen_string_literal: true

require_relative 'base_general_image_projection_transformer'

module GDAL
  module Transformers
    class GeneralImageProjectionTransformer2 < BaseGeneralImageProjectionTransformer
      attr_reader :c_pointer

      # @param source_dataset [GDAL::Dataset, FFI::Pointer]
      # @param destination_dataset [GDAL::Dataset, FFI::Pointer]
      # @param options [Hash]
      # @option options [String] src_srs Use to override +source_dataset+'s WKT
      #   SRS.
      # @option options [String] dst_srs Use to override +destination_dataset+'s WKT
      #   SRS.
      # @option options [Boolean] gcps_ok (true)
      # @option options [Integer] refine_minimum_gcps Minimum amount of GCPs that
      #   should be available after the refinement.
      # @option options [Float] refine_tolerance The tolerance that specifies
      #   when a GCP will be eliminated.
      # @option options [Integer] max_gcp_order Max order to use for GCP-derived
      #   polynomials, if possible. Default is to auto-select based on the number
      #   of GCPs. A value of -1 triggers use of Thin Plate Spline instead of
      #   polynomials.
      # @option options [String] src_method GEOTRANSFORM, GCP_POLYNOMIAL, GCP_TPS,
      #   GEOLOC_ARRAY, or RPC. Use this specific geolocation method when
      #   transforming pixel/line to georeferenced space on the source dataset.
      # @option options [String] dst_method GEOTRANSFORM, GCP_POLYNOMIAL, GCP_TPS,
      #   GEOLOC_ARRAY, or RPC. Use this specific geolocation method when
      #   transforming pixel/line to georeferenced space on the destination
      #   dataset.
      # @option options [Float] rpc_height A fixed height to be used with RPC
      #   calculations.
      # @option options [String] rpc_dem Name of a DEM file to be used with RPC
      #   calculations.
      # @option options [Boolean] insert_center_long (true) False disables setting
      #   up a CENTER_LONG value on the coordinate system to rewrap things around
      #   the center of the image.
      def initialize(source_dataset, destination_dataset: nil, **options)
        super()

        source_ptr = GDAL::Dataset.new_pointer(source_dataset)
        destination_ptr = GDAL::Dataset.new_pointer(destination_dataset, warn_on_nil: false)
        options_ptr = GDAL::Options.pointer(options)

        pointer = FFI::GDAL::Alg.GDALCreateGenImgProjTransformer2(
          source_ptr,
          destination_ptr,
          options_ptr
        )
        raise if pointer.null?

        init_pointer(pointer)
      end
    end
  end
end
