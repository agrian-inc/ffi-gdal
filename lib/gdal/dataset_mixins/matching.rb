# typed: false
# frozen_string_literal: true

module GDAL
  module DatasetMixins
    module Matching
      # @param other_dataset [GDAL::Dataset]
      # @param options [Hash]
      # @return [Hash{count => Integer, gcp: => FFI::GDAL::GCP}] Not sure why,
      #   but the C function seems to return a single GCP instead of an Array of
      #   them.
      def compute_matching_points(other_dataset, **options)
        other_dataset_ptr = GDAL._pointer(GDAL::Dataset, other_dataset)
        options_ptr = GDAL::Options.pointer(options)
        gcp_count_ptr = FFI::MemoryPointer.new(:int)

        gcp = FFI::GDAL::Matching.GDALComputeMatchingPoints(
          @c_pointer,
          other_dataset_ptr,
          options_ptr,
          gcp_count_ptr
        )

        { count: gcp_count_ptr.read_int, gcp: gcp }
      end
    end
  end
end
