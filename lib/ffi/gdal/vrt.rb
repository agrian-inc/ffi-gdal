# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module GDAL
    module VRT
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #-------------------------------------------------------------------------
      # Typedefs
      #-------------------------------------------------------------------------
      typedef :pointer, :VRTDriverH

      typedef :pointer, :VRTSourceH
      typedef :pointer, :VRTSimpleSourceH
      typedef :pointer, :VRTAveragedSourceH
      typedef :pointer, :VRTComplexSourceH
      typedef :pointer, :VRTFilteredSourceH
      typedef :pointer, :VRTKernelFilteredSourceH
      typedef :pointer, :VRTAverageFilteredSourceH
      typedef :pointer, :VRTFuncSourceH

      typedef :pointer, :VRTDatasetH
      typedef :pointer, :VRTWarpedDatasetH

      typedef :pointer, :VRTRasterBandH
      typedef :pointer, :VRTSourcedRasterBandH
      typedef :pointer, :VRTWarpedRasterBandH
      typedef :pointer, :VRTDerivedRasterBandH
      typedef :pointer, :VRTRawRasterBandH

      callback :VRTImageReadFunc,
               %i[pointer int int int int pointer],
               CPL::Error::CPLErr

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_function :GDALRegister_VRT, [], :void
      attach_function :VRTCreate, %i[int int], :VRTDatasetH
      attach_function :VRTFlushCache, %i[VRTDatasetH], :void
      attach_function :VRTSerializeToXML, %i[VRTDatasetH string], CPL::XMLNode.ptr

      attach_function :VRTAddBand,
                      [:VRTDatasetH, GDAL::DataType, :pointer],
                      :int

      attach_function :VRTAddSource,
                      %i[VRTSourcedRasterBandH VRTSourceH],
                      CPL::Error::CPLErr
      attach_function :VRTAddSimpleSource,
                      [
                        :VRTSourcedRasterBandH,             # hVRTBand
                        GDAL.find_type(:GDALRasterBandH),   # hSrcBand
                        :int,                               # nSrcXOff
                        :int,                               # nSrcYOff
                        :int,                               # nSrcXSize
                        :int,                               # nSrcYSize
                        :int,                               # nDstXOff
                        :int,                               # nDstYOff
                        :int,                               # nDstXSize
                        :int,                               # nDstYSize
                        :string,                            # pszResampling
                        :double                             # dfNoDataValue
                      ],
                      CPL::Error::CPLErr
      attach_function :VRTAddComplexSource,
                      [
                        :VRTSourcedRasterBandH,             # hVRTBand
                        GDAL.find_type(:GDALRasterBandH),   # hSrcBand
                        :int,                               # nSrcXOff
                        :int,                               # nSrcYOff
                        :int,                               # nSrcXSize
                        :int,                               # nSrcYSize
                        :int,                               # nDstXOff
                        :int,                               # nDstYOff
                        :int,                               # nDstXSize
                        :int,                               # nDstYSize
                        :double,                            # dfScaleOff
                        :double,                            # dfScaleRation
                        :double                             # dfNoDataValue
                      ],
                      CPL::Error::CPLErr
      attach_function :VRTAddFuncSource,
                      %i[VRTSourcedRasterBandH VRTImageReadFunc pointer double],
                      CPL::Error::CPLErr
    end
  end
end
