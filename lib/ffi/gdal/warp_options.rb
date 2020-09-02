# typed: true
# frozen_string_literal: true

require 'ffi'

module FFI
  module GDAL
    class WarpOptions < FFI::Struct
      layout :warp_operation_options, :pointer,
             :warp_memory_limit, :double,
             :resample_alg, FFI::GDAL::Warper::ResampleAlg,
             :working_data_type, FFI::GDAL::GDAL::DataType,
             :source_dataset, GDAL.find_type(:GDALDatasetH),
             :destination_dataset, GDAL.find_type(:GDALDatasetH),
             :band_count, :int,
             :source_bands, :pointer,
             :destination_bands, :pointer,
             :source_alpha_band, :int,
             :destination_alpha_band, :int,
             :source_no_data_real, :pointer,
             :source_no_data_imaginary, :pointer,
             :destination_no_data_real, :pointer,
             :destination_no_data_imaginary, :pointer,
             :progress, GDAL.find_type(:GDALProgressFunc),
             :progress_arg, :pointer,
             :transformer, Alg.find_type(:GDALTransformerFunc),
             :transformer_arg, :pointer,
             :source_per_band_validity_mask_function, :pointer,
             :source_per_band_validity_mask_function_arg, :pointer,
             :source_validity_mask_function, Warper.find_type(:GDALMaskFunc),
             :source_validity_mask_function_arg, :pointer,
             :source_density_mask_function, Warper.find_type(:GDALMaskFunc),
             :source_density_mask_function_arg, :pointer,
             :destination_density_mask_function, Warper.find_type(:GDALMaskFunc),
             :destination_density_mask_function_arg, :pointer,
             :destination_validity_mask_function, Warper.find_type(:GDALMaskFunc),
             :destination_validity_mask_function_arg, :pointer,
             :pre_warp_chunk_processor, callback(%i[pointer pointer], CPL::Error::CPLErr),
             :pre_warp_processor_arg, :pointer,
             :post_warp_chunk_processor, callback(%i[pointer pointer], CPL::Error::CPLErr),
             :post_warp_processor_arg, :pointer,
             :cutline, :pointer,
             :cutline_blend_distance, :double

      def initialize
        super
        self[:progress] = proc { true } if self[:progress].null?
      end
    end
  end
end
