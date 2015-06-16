require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module GDAL
    module Grid
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      callback :GDALGridFunction,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :GDALGridInverseDistanceToAPower,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr
      attach_function :GDALGridInverseDistanceToAPointerNoSearch,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr

      attach_function :GDALGridMovingAverage,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr

      attach_function :GDALGridNearestNeighbor,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr

      attach_function :GDALGridDataMetricMinimum,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr
      attach_function :GDALGridDataMetricMaximum,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr
      attach_function :GDALGridDataMetricRange,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr
      attach_function :GDALGridDataMetricCount,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr
      attach_function :GDALGridDataMetricAverageDistance,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr
      attach_function :GDALGridDataMetricAverageDistancePts,
        %i[pointer GUInt32 pointer pointer pointer double double pointer pointer],
        CPLErr
      attach_function :ParseAlgorithmAndOptions,
        [:string, GDALGridAlgorithm, :pointer],
        CPLErr
    end
  end
end