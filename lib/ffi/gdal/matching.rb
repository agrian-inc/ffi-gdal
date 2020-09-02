# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module GDAL
    module Matching
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      # TODO: Seems like this should return an array of GCPs, not just a single
      # GCP.
      attach_function :GDALComputeMatchingPoints,
                      [GDAL.find_type(:GDALDatasetH), GDAL.find_type(:GDALDatasetH), :pointer, :pointer],
                      # :pointer
                      GCP.ptr
    end
  end
end
