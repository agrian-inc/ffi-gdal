# typed: true
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module GDAL
    module Warper
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :pointer, :GDALWarpOperationH
      MaskFunc = callback :GDALMaskFunc,
                          [
                            :pointer,
                            :int,
                            FFI::GDAL::GDAL::DataType,
                            :int,
                            :int,
                            :int,
                            :int,
                            :pointer,
                            :int,
                            :pointer
                          ],
                          :pointer

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      ResampleAlg = enum :GRA_NearestNeighbor, 0,
                         :GRA_Bilinear, 1,
                         :GRA_Cubic, 2,
                         :GRA_CubicSpline, 3,
                         :GRA_Lanczos, 4,
                         :GRA_Average, 5,
                         :GRA_Mode, 6

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :GDALCreateWarpOptions, [], FFI::GDAL::WarpOptions.ptr
      attach_function :GDALDestroyWarpOptions, [FFI::GDAL::WarpOptions.ptr], :void
      attach_function :GDALCloneWarpOptions, [FFI::GDAL::WarpOptions.ptr], FFI::GDAL::WarpOptions.ptr
      attach_function :GDALSerializeWarpOptions,
                      [FFI::GDAL::WarpOptions.ptr],
                      FFI::CPL::XMLNode.ptr
      attach_function :GDALDeserializeWarpOptions,
                      [FFI::CPL::XMLNode.ptr],
                      FFI::GDAL::WarpOptions.ptr

      attach_function :GDALCreateWarpOperation,
                      [FFI::GDAL::WarpOptions.ptr],
                      :GDALWarpOperationH
      attach_function :GDALDestroyWarpOperation, %i[GDALWarpOperationH], :void

      attach_function :GDALWarpNoDataMasker,
                      [:pointer, :int, GDAL::DataType, :int, :int, :int, :int, :pointer, :int, :pointer],
                      CPL::Error::CPLErr
      attach_function :GDALWarpDstAlphaMasker,
                      [:pointer, :int, GDAL::DataType, :int, :int, :int, :int, :pointer, :int, :pointer],
                      CPL::Error::CPLErr
      attach_function :GDALWarpSrcAlphaMasker,
                      [:pointer, :int, GDAL::DataType, :int, :int, :int, :int, :pointer, :int, :pointer],
                      CPL::Error::CPLErr
      attach_function :GDALWarpSrcMaskMasker,
                      [:pointer, :int, GDAL::DataType, :int, :int, :int, :int, :pointer, :int, :pointer],
                      CPL::Error::CPLErr
      attach_function :GDALWarpCutlineMasker,
                      [:pointer, :int, GDAL::DataType, :int, :int, :int, :int, :pointer, :int, :pointer],
                      CPL::Error::CPLErr

      attach_function :GDALReprojectImage,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        ResampleAlg,
                        :double,
                        :double,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer,
                        FFI::GDAL::WarpOptions.ptr
                      ],
                      CPL::Error::CPLErr
      attach_function :GDALCreateAndReprojectImage,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        :string,
                        :string,
                        FFI::GDAL::GDAL.find_type(:GDALDriverH),
                        :pointer,
                        ResampleAlg,
                        :double,
                        :double,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer,
                        FFI::GDAL::WarpOptions.ptr
                      ],
                      CPL::Error::CPLErr
      attach_function :GDALAutoCreateWarpedVRT,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        :string,
                        ResampleAlg,
                        :double,
                        FFI::GDAL::WarpOptions.ptr
                      ],
                      FFI::GDAL::GDAL.find_type(:GDALDatasetH)
      attach_function :GDALCreateWarpedVRT,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :int,
                        :int,
                        :double,
                        FFI::GDAL::WarpOptions.ptr
                      ],
                      FFI::GDAL::GDAL.find_type(:GDALDatasetH)
      attach_function :GDALInitializeWarpedVRT,
                      [FFI::GDAL::GDAL.find_type(:GDALDatasetH), FFI::GDAL::WarpOptions.ptr],
                      CPL::Error::CPLErr

      attach_function :GDALChunkAndWarpImage,
                      %i[GDALWarpOperationH int int int int],
                      CPL::Error::CPLErr
      attach_function :GDALChunkAndWarpMulti,
                      %i[GDALWarpOperationH int int int int],
                      CPL::Error::CPLErr
      attach_function :GDALWarpRegion,
                      %i[GDALWarpOperationH int int int int int int int int],
                      CPL::Error::CPLErr
      attach_function :GDALWarpRegionToBuffer,
                      [:GDALWarpOperationH, :int, :int, :int, :int, :pointer, GDAL::DataType, :int, :int, :int, :int],
                      CPL::Error::CPLErr
    end
  end
end
