# typed: strict
# frozen_string_literal: true

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
               [
                 :pointer,
                 CPL::Port.find_type(:GUInt32),
                 :pointer,
                 :pointer,
                 :pointer,
                 :double,
                 :double,
                 :pointer,
                 :pointer
               ],
               CPL::Error::CPLErr

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :GDALGridInverseDistanceToAPower,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridInverseDistanceToAPointerNoSearch,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridMovingAverage,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridNearestNeighbor,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridDataMetricMinimum,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridDataMetricMaximum,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridDataMetricRange,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridDataMetricCount,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridDataMetricAverageDistance,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :GDALGridDataMetricAverageDistancePts,
                      [
                        :pointer,
                        CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :pointer,
                        :pointer
                      ],
                      CPL::Error::CPLErr

      attach_function :ParseAlgorithmAndOptions,
                      [:string, Alg::GridAlgorithm, :pointer],
                      CPL::Error::CPLErr
    end
  end
end
