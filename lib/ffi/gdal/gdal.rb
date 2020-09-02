# typed: true
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative 'color_entry'

module FFI
  module GDAL
    module GDAL
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      # ----------------------------------------------------------------
      # Enums
      # ----------------------------------------------------------------
      DataType = enum :GDT_Unknown, 0,
                      :GDT_Byte,        1,
                      :GDT_UInt16,      2,
                      :GDT_Int16,       3,
                      :GDT_UInt32,      4,
                      :GDT_Int32,       5,
                      :GDT_Float32,     6,
                      :GDT_Float64,     7,
                      :GDT_CInt16,      8,
                      :GDT_CInt32,      9,
                      :GDT_CFloat32,    10,
                      :GDT_CFloat64,    11,
                      :GDT_TypeCount,   12

      AsyncStatusType = enum :GARIO_PENDING, 0,
                             :GARIO_UPDATE,     1,
                             :GARIO_ERROR,      2,
                             :GARIO_COMPLETE,   3,
                             :GARIO_TypeCount,  4

      Access = enum :GA_ReadOnly, 0,
                    :GA_Update, 1

      RWFlag = enum :GF_Read, 0,
                    :GF_Write, 1

      ColorInterp = enum :GCI_Undefined, 0,
                         :GCI_GrayIndex,      1,
                         :GCI_PaletteIndex,   2,
                         :GCI_RedBand,        3,
                         :GCI_GreenBand,      4,
                         :GCI_BlueBand,       5,
                         :GCI_AlphaBand,      6,
                         :GCI_HueBand,        7,
                         :GCI_SaturationBand, 8,
                         :GCI_LightnessBand,  9,
                         :GCI_CyanBand,       10,
                         :GCI_MagentaBand,    11,
                         :GCI_YellowBand,     12,
                         :GCI_BlackBand,      13,
                         :GCI_YCbCr_YBand,    14,
                         :GCI_YCbCr_CbBand,   15,
                         :GCI_YCbCr_CrBand,   16,
                         :GCI_Max, 16 # Seems wrong that this is also 16...

      PaletteInterp = enum :GPI_Gray, 0,
                           :GPI_RGB,   1,
                           :GPI_CMYK,  2,
                           :GPI_HLS,   3

      RATFieldType = enum :GFT_Integer,
                          :GFT_Real,
                          :GFT_String

      RATFieldUsage = enum :GFU_Generic, 0,
                           :GFU_PixelCount,  1,
                           :GFU_Name,        2,
                           :GFU_Min,         3,
                           :GFU_Max,         4,
                           :GFU_MinMax,      5,
                           :GFU_Red,         6,
                           :GFU_Green,       7,
                           :GFU_Blue,        8,
                           :GFU_Alpha,       9,
                           :GFU_RedMin,     10,
                           :GFU_GreenMin,   11,
                           :GFU_BlueMin,    12,
                           :GFU_AlphaMin,   13,
                           :GFU_RedMax,     14,
                           :GFU_GreenMax,   15,
                           :GFU_BlueMax,    16,
                           :GFU_AlphaMax,   17,
                           :GFU_MaxCount

      TileOrganization = enum :GTO_TIP,
                              :GTO_BIT,
                              :GTO_BSQ

      # ----------------------------------------------------------------
      # typedefs
      # ----------------------------------------------------------------
      typedef :pointer, :GDALMajorObjectH
      typedef :pointer, :GDALDatasetH
      typedef :pointer, :GDALRasterBandH
      typedef :pointer, :GDALDriverH
      typedef :pointer, :GDALColorTableH
      typedef :pointer, :GDALRasterAttributeTableH
      typedef :pointer, :GDALAsyncReaderH

      # When using, make sure to return +true+ if the operation should continue;
      #   +false+ if the user has canceled.
      callback :GDALProgressFunc,
               %i[double string pointer], # completion, message, progress_arg
               :bool

      callback :GDALDerivedPixelFunc,
               [:pointer, :int, :pointer, :int, :int, DataType, DataType, :int, :int],
               :int

      # ----------------------------------------------------------------
      # functions
      # ----------------------------------------------------------------
      # AsyncStatus
      attach_function :GDALGetAsyncStatusTypeName, [AsyncStatusType], :string
      attach_function :GDALGetAsyncStatusTypeByName, [:string], AsyncStatusType

      # ~~~~~~~~~~~~~~~~~~~
      # ColorInterpretation
      # ~~~~~~~~~~~~~~~~~~~
      attach_function :GDALGetColorInterpretationName, [ColorInterp], :strptr
      attach_function :GDALGetColorInterpretationByName, [:string], ColorInterp

      # ~~~~~~~~~~~~~~~~~~~
      # Driver
      # ~~~~~~~~~~~~~~~~~~~
      attach_function :GDALAllRegister, [], :void

      # Class-level functions
      attach_function :GDALGetDriver, [:int], :GDALDriverH
      attach_function :GDALGetDriverCount, [], :int
      attach_function :GDALIdentifyDriver, %i[string pointer], :GDALDriverH
      attach_function :GDALGetDriverByName, [:string], :GDALDriverH
      attach_function :GDALDestroyDriverManager, [], :void

      # Instance-level functions
      attach_function :GDALCreate,
                      [:GDALDriverH, :string, :int, :int, :int, DataType, :pointer],
                      :GDALDatasetH
      attach_function :GDALCreateCopy,
                      %i[GDALDriverH string GDALDatasetH bool pointer GDALProgressFunc pointer],
                      :GDALDatasetH
      attach_function :GDALValidateCreationOptions, %i[GDALDriverH pointer], :bool
      attach_function :GDALGetDriverShortName, [:GDALDriverH], :strptr
      attach_function :GDALGetDriverLongName, [:GDALDriverH], :strptr
      attach_function :GDALGetDriverHelpTopic, [:GDALDriverH], :strptr
      attach_function :GDALGetDriverCreationOptionList, [:GDALDriverH], :strptr

      attach_function :GDALDestroyDriver, [:GDALDriverH], :void
      attach_function :GDALRegisterDriver, [:GDALDriverH], :int
      attach_function :GDALDeregisterDriver, [:GDALDriverH], :void
      attach_function :GDALDeleteDataset, %i[GDALDriverH string], FFI::CPL::Error::CPLErr
      attach_function :GDALRenameDataset,
                      %i[GDALDriverH string string],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALCopyDatasetFiles,
                      %i[GDALDriverH string string],
                      FFI::CPL::Error::CPLErr

      # ~~~~~~~~~~~~~~~~~~~
      # Dataset
      # ~~~~~~~~~~~~~~~~~~~
      # Class-level functions
      attach_function :GDALOpen, [:string, Access], :GDALDatasetH
      attach_function :GDALOpenShared,
                      [:string, Access],
                      :GDALDatasetH
      attach_function :GDALDumpOpenDatasets, [:pointer], :int
      attach_function :GDALGetOpenDatasets, %i[pointer pointer], :void

      # Instance-level functions
      attach_function :GDALClose, [:GDALDatasetH], :void
      attach_function :GDALGetDatasetDriver, [:GDALDatasetH], :GDALDriverH
      attach_function :GDALGetFileList, [:GDALDatasetH], :pointer
      attach_function :GDALGetInternalHandle, %i[GDALDatasetH string], :pointer
      attach_function :GDALReferenceDataset, [:GDALDatasetH], :int
      attach_function :GDALDereferenceDataset, [:GDALDatasetH], :int

      attach_function :GDALGetAccess, [:GDALDatasetH], :int
      attach_function :GDALFlushCache, [:GDALDatasetH], :void

      attach_function :GDALGetRasterXSize, [:GDALDatasetH], :int
      attach_function :GDALGetRasterYSize, [:GDALDatasetH], :int
      attach_function :GDALGetRasterCount, [:GDALDatasetH], :int
      attach_function :GDALGetRasterBand, %i[GDALDatasetH int], :GDALRasterBandH
      attach_function :GDALAddBand,
                      [:GDALDatasetH, DataType, :pointer],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALBeginAsyncReader,
                      [
                        :GDALDatasetH,
                        RWFlag,
                        :int,
                        :int,
                        :int,
                        :int,
                        :pointer,
                        :int,
                        :int,
                        DataType,
                        :int,
                        :pointer,
                        :int,
                        :int,
                        :int
                      ], :GDALAsyncReaderH

      attach_function :GDALEndAsyncReader,
                      %i[GDALDatasetH GDALAsyncReaderH],
                      :void

      attach_function :GDALDatasetRasterIO,
                      [
                        :GDALDatasetH,
                        RWFlag,
                        :int,
                        :int,
                        :int,
                        :int,
                        :pointer,
                        :int,
                        :int,
                        DataType,
                        :int,
                        :pointer,
                        :int,
                        :int,
                        :int
                      ], FFI::CPL::Error::CPLErr

      attach_function :GDALDatasetAdviseRead,
                      [
                        :GDALDatasetH,
                        :int,
                        :int,
                        :int,
                        :int,
                        :int,
                        :int,
                        DataType,
                        :int,
                        :pointer,
                        :pointer
                      ], FFI::CPL::Error::CPLErr

      attach_function :GDALInitGCPs, %i[int pointer], :void
      attach_function :GDALDeinitGCPs, %i[int pointer], :void
      attach_function :GDALDuplicateGCPs, %i[int pointer], :pointer
      attach_function :GDALGCPsToGeoTransform,
                      %i[int pointer pointer int],
                      :int
      attach_function :GDALGetGCPCount, [:GDALDatasetH], :int
      attach_function :GDALGetGCPProjection, [:GDALDatasetH], :strptr
      attach_function :GDALGetGCPs, [:GDALDatasetH], :pointer
      attach_function :GDALSetGCPs,
                      %i[GDALDatasetH int pointer string],
                      FFI::CPL::Error::CPLErr

      attach_function :GDALGetProjectionRef, [:GDALDatasetH], :strptr
      attach_function :GDALSetProjection, %i[GDALDatasetH string], FFI::CPL::Error::CPLErr
      attach_function :GDALGetGeoTransform, %i[GDALDatasetH pointer], FFI::CPL::Error::CPLErr
      attach_function :GDALSetGeoTransform,
                      %i[GDALDatasetH pointer],
                      FFI::CPL::Error::CPLErr

      attach_function :GDALBuildOverviews,
                      %i[
                        GDALDatasetH
                        string
                        int
                        pointer
                        int
                        pointer
                        GDALProgressFunc
                        pointer
                      ], FFI::CPL::Error::CPLErr

      # OGR datasets.  Not found in v1.11.1
      # attach_function :GDALDatasetGetLayerCount, [:GDALDatasetH], :int
      # attach_function :GDALDatasetGetLayer, [:GDALDatasetH, :int], :OGRLayerH
      # attach_function :GDALDatasetGetLayerByName, [:GDALDatasetH, :string], :OGRLayerH
      # attach_function :GDALDatasetDeleteLayer, [:GDALDatasetH, :int], FFI::OGR::::OGRErr
      # attach_function :GDALDatasetCreateLayer,
      #   [
      #     :GDALDatasetH,
      #     :string,
      #     FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH),
      #     FFI::OGR::::OGRwkbGeometryType,
      #     :pointer
      #   ],
      #   :OGRLayerH
      # attach_function :GDALDatasetCopyLayer,
      #   [:GDALDatasetH, :OGRLayerH, :string, :pointer],
      #   :OGRLayerH
      # attach_function :GDALDatasetTestCapability, [:GDALDatasetH, :string], :int
      # attach_function :GDALDatasetExecuteSQL,
      #   [:GDALDatasetH, :string, :OGRGeometryH, :string],
      #   :OGRLayerH
      # attach_function :GDALDatasetReleaseResultSet,
      #   %i[GDALDatasetH OGRLayerH],
      #   :void
      # attach_function :GDALDatasetGetStyleTable, [:GDALDatasetH], :OGRStyleTableH
      # attach_function :GDALDatasetSetStyleTableDirectly,
      #   %i[GDALDatasetH OGRStyleTableH],
      #   :void
      # attach_function :GDALDatasetSetStyleTable,
      #   %i[GDALDatasetH OGRStyleTableH],
      #   :void

      attach_function :GDALCreateDatasetMaskBand, %i[GDALDatasetH int], FFI::CPL::Error::CPLErr
      attach_function :GDALDatasetCopyWholeRaster,
                      %i[GDALDatasetH GDALDatasetH pointer GDALProgressFunc pointer],
                      FFI::CPL::Error::CPLErr

      # ~~~~~~~~~~~~~~~~~~~
      # MajorObject
      # ~~~~~~~~~~~~~~~~~~~
      attach_function :GDALGetMetadataDomainList, [:GDALMajorObjectH], :pointer
      attach_function :GDALGetMetadata, %i[GDALMajorObjectH string], :pointer
      attach_function :GDALSetMetadata, %i[GDALMajorObjectH pointer string], FFI::CPL::Error::CPLErr
      attach_function :GDALGetMetadataItem,
                      %i[GDALMajorObjectH string string],
                      :strptr
      attach_function :GDALSetMetadataItem,
                      %i[GDALMajorObjectH string string string],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALGetDescription, [:GDALMajorObjectH], :strptr
      attach_function :GDALSetDescription, %i[GDALMajorObjectH string], :void

      # ~~~~~~~~~~~~~~~~~~~
      # GeoTransform
      # ~~~~~~~~~~~~~~~~~~~
      attach_function :GDALInvGeoTransform, %i[pointer pointer], :int
      attach_function :GDALApplyGeoTransform,
                      %i[pointer double double pointer pointer],
                      :void
      attach_function :GDALComposeGeoTransforms,
                      %i[pointer pointer pointer],
                      :void

      # ----------------
      # Raster functions
      # ----------------
      attach_function :GDALRasterBandCopyWholeRaster,
                      %i[
                        GDALRasterBandH
                        GDALRasterBandH
                        pointer
                        GDALProgressFunc
                        pointer
                      ], FFI::CPL::Error::CPLErr
      attach_function :GDALRegenerateOverviews,
                      %i[
                        GDALRasterBandH
                        int
                        pointer
                        string
                        GDALProgressFunc
                        pointer
                      ], FFI::CPL::Error::CPLErr
      attach_function :GDALGetMaskBand, [:GDALRasterBandH], :GDALRasterBandH
      attach_function :GDALGetMaskFlags, [:GDALRasterBandH], :int
      attach_function :GDALCreateMaskBand,
                      %i[GDALRasterBandH int],
                      FFI::CPL::Error::CPLErr

      attach_function :GDALGetRasterDataType, [:GDALRasterBandH], DataType
      attach_function :GDALGetBlockSize,
                      %i[GDALRasterBandH pointer pointer],
                      DataType

      attach_function :GDALRasterAdviseRead,
                      [
                        :GDALRasterBandH,
                        :int,
                        :int,
                        :int,
                        :int,
                        :int,
                        :int,
                        DataType,
                        :pointer
                      ], FFI::CPL::Error::CPLErr

      attach_function :GDALRasterIO,
                      [
                        :GDALRasterBandH,
                        RWFlag,
                        :int,
                        :int,
                        :int,
                        :int,
                        :pointer,
                        :int,
                        :int,
                        DataType,
                        :int,
                        :int
                      ], FFI::CPL::Error::CPLErr
      attach_function :GDALReadBlock,
                      %i[GDALRasterBandH int int pointer],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALWriteBlock,
                      %i[GDALRasterBandH int int pointer],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALGetRasterBandXSize, [:GDALRasterBandH], :int
      attach_function :GDALGetRasterBandYSize, [:GDALRasterBandH], :int
      attach_function :GDALGetRasterAccess, [:GDALRasterBandH], Access
      attach_function :GDALGetBandNumber, [:GDALRasterBandH], :int
      attach_function :GDALGetBandDataset, [:GDALRasterBandH], :GDALDatasetH
      attach_function :GDALGetRasterColorInterpretation,
                      [:GDALRasterBandH],
                      ColorInterp
      attach_function :GDALSetRasterColorInterpretation,
                      [:GDALRasterBandH, ColorInterp],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALGetRasterColorTable,
                      [:GDALRasterBandH],
                      :GDALColorTableH
      attach_function :GDALSetRasterColorTable,
                      %i[GDALRasterBandH GDALColorTableH],
                      FFI::CPL::Error::CPLErr

      attach_function :GDALHasArbitraryOverviews, [:GDALRasterBandH], :int
      attach_function :GDALGetOverviewCount, [:GDALRasterBandH], :int
      attach_function :GDALGetOverview, %i[GDALRasterBandH int], :GDALRasterBandH
      attach_function :GDALGetRasterNoDataValue,
                      %i[GDALRasterBandH pointer],
                      :double
      attach_function :GDALSetRasterNoDataValue,
                      %i[GDALRasterBandH double],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALGetRasterCategoryNames,
                      [:GDALRasterBandH],
                      :pointer
      attach_function :GDALSetRasterCategoryNames,
                      %i[GDALRasterBandH pointer],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALGetRasterMinimum,
                      %i[GDALRasterBandH pointer],
                      :double
      attach_function :GDALGetRasterMaximum,
                      %i[GDALRasterBandH pointer],
                      :double
      attach_function :GDALGetRasterStatistics,
                      %i[GDALRasterBandH bool bool pointer pointer pointer pointer],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALComputeRasterStatistics,
                      %i[
                        GDALRasterBandH
                        bool
                        pointer
                        pointer
                        pointer
                        pointer
                        GDALProgressFunc
                        pointer
                      ], FFI::CPL::Error::CPLErr
      attach_function :GDALSetRasterStatistics,
                      %i[GDALRasterBandH double double double double],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALGetRasterUnitType, [:GDALRasterBandH], :strptr
      attach_function :GDALSetRasterUnitType, %i[GDALRasterBandH string], FFI::CPL::Error::CPLErr
      attach_function :GDALGetRasterOffset, %i[GDALRasterBandH pointer], :double
      attach_function :GDALSetRasterOffset, %i[GDALRasterBandH double], FFI::CPL::Error::CPLErr
      attach_function :GDALGetRasterScale, %i[GDALRasterBandH pointer], :double
      attach_function :GDALSetRasterScale, %i[GDALRasterBandH double], FFI::CPL::Error::CPLErr
      attach_function :GDALComputeRasterMinMax,
                      %i[GDALRasterBandH bool pointer],
                      :void
      attach_function :GDALFlushRasterCache, [:GDALRasterBandH], FFI::CPL::Error::CPLErr
      attach_function :GDALGetRasterHistogram,
                      %i[
                        GDALRasterBandH
                        double
                        double
                        int
                        pointer
                        bool
                        bool
                        GDALProgressFunc
                        pointer
                      ], FFI::CPL::Error::CPLErr

      attach_function :GDALGetDefaultHistogram,
                      %i[
                        GDALRasterBandH
                        pointer
                        pointer
                        pointer
                        pointer
                        bool
                        GDALProgressFunc
                        pointer
                      ], FFI::CPL::Error::CPLErr
      attach_function :GDALSetDefaultHistogram,
                      %i[
                        GDALRasterBandH
                        double
                        double
                        int
                        pointer
                      ], FFI::CPL::Error::CPLErr

      attach_function :GDALGetRandomRasterSample,
                      %i[GDALRasterBandH int pointer],
                      :int
      attach_function :GDALGetRasterSampleOverview,
                      %i[GDALRasterBandH int],
                      :GDALRasterBandH
      attach_function :GDALFillRaster,
                      %i[GDALRasterBandH double double],
                      FFI::CPL::Error::CPLErr

      attach_function :GDALGetDefaultRAT,
                      [:GDALRasterBandH],
                      :GDALRasterAttributeTableH
      attach_function :GDALSetDefaultRAT,
                      %i[GDALRasterBandH GDALRasterAttributeTableH],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALAddDerivedBandPixelFunc,
                      %i[string GDALDerivedPixelFunc],
                      FFI::CPL::Error::CPLErr

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Raster Attribute Table functions
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Class-level functions
      attach_function :GDALCreateRasterAttributeTable,
                      [],
                      :GDALRasterAttributeTableH

      # Instance-level functions
      attach_function :GDALDestroyRasterAttributeTable,
                      [:GDALRasterAttributeTableH],
                      :void
      attach_function :GDALRATChangesAreWrittenToFile,
                      [:GDALRasterAttributeTableH],
                      :bool
      attach_function :GDALRATClone,
                      [:GDALRasterAttributeTableH],
                      :GDALRasterAttributeTableH

      attach_function :GDALRATGetColumnCount,
                      [:GDALRasterAttributeTableH],
                      :int
      attach_function :GDALRATGetNameOfCol,
                      %i[GDALRasterAttributeTableH int],
                      :strptr
      attach_function :GDALRATGetUsageOfCol,
                      %i[GDALRasterAttributeTableH int],
                      RATFieldUsage
      attach_function :GDALRATGetTypeOfCol,
                      %i[GDALRasterAttributeTableH int],
                      RATFieldType
      attach_function :GDALRATGetColOfUsage,
                      [:GDALRasterAttributeTableH, RATFieldUsage],
                      :int
      attach_function :GDALRATCreateColumn,
                      [:GDALRasterAttributeTableH, :string, RATFieldType, RATFieldUsage],
                      FFI::CPL::Error::CPLErr

      attach_function :GDALRATGetValueAsString,
                      %i[GDALRasterAttributeTableH int int],
                      :strptr
      attach_function :GDALRATGetValueAsInt,
                      %i[GDALRasterAttributeTableH int int],
                      :int
      attach_function :GDALRATGetValueAsDouble,
                      %i[GDALRasterAttributeTableH int int],
                      :double
      attach_function :GDALRATSetValueAsString,
                      %i[GDALRasterAttributeTableH int int string],
                      :void
      attach_function :GDALRATSetValueAsInt,
                      %i[GDALRasterAttributeTableH int int int],
                      :void
      attach_function :GDALRATSetValueAsDouble,
                      %i[GDALRasterAttributeTableH int int double],
                      :void
      attach_function :GDALRATValuesIOAsDouble,
                      [:GDALRasterAttributeTableH, RWFlag, :int, :int, :int, :pointer],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALRATValuesIOAsInteger,
                      [:GDALRasterAttributeTableH, RWFlag, :int, :int, :int, :pointer],
                      FFI::CPL::Error::CPLErr
      attach_function :GDALRATValuesIOAsString,
                      [:GDALRasterAttributeTableH, RWFlag, :int, :int, :int, :pointer],
                      FFI::CPL::Error::CPLErr

      attach_function :GDALRATGetRowCount,
                      [:GDALRasterAttributeTableH],
                      :int
      attach_function :GDALRATSetRowCount,
                      %i[GDALRasterAttributeTableH int],
                      :void
      attach_function :GDALRATGetRowOfValue,
                      %i[GDALRasterAttributeTableH double],
                      :int

      attach_function :GDALRATSetLinearBinning,
                      %i[GDALRasterAttributeTableH double double],
                      :int
      attach_function :GDALRATGetLinearBinning,
                      %i[GDALRasterAttributeTableH pointer pointer],
                      :bool
      attach_function :GDALRATTranslateToColorTable,
                      %i[GDALRasterAttributeTableH int],
                      :GDALColorTableH
      attach_function :GDALRATInitializeFromColorTable,
                      %i[GDALRasterAttributeTableH GDALColorTableH],
                      FFI::CPL::Error::CPLErr

      attach_function :GDALRATDumpReadable,
                      %i[GDALRasterAttributeTableH pointer],
                      :void

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # ColorTable functions
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Class-level functions
      attach_function :GDALCreateColorTable, [PaletteInterp], :GDALColorTableH

      # Instance-level functions
      attach_function :GDALDestroyColorTable, [:GDALColorTableH], :void
      attach_function :GDALCloneColorTable, [:GDALColorTableH], :GDALColorTableH

      attach_function :GDALGetPaletteInterpretation, [:GDALColorTableH], PaletteInterp
      attach_function :GDALGetColorEntryCount, [:GDALColorTableH], :int
      attach_function :GDALGetColorEntry, %i[GDALColorTableH int], FFI::GDAL::ColorEntry.ptr
      attach_function :GDALGetColorEntryAsRGB, [:GDALColorTableH, :int, FFI::GDAL::ColorEntry], :int
      attach_function :GDALSetColorEntry, [:GDALColorTableH, :int, FFI::GDAL::ColorEntry.ptr], :void

      attach_function :GDALCreateColorRamp,
                      [:GDALColorTableH, :int, FFI::GDAL::ColorEntry.ptr, :int, FFI::GDAL::ColorEntry.ptr],
                      :void

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # PaletteInterp functions
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attach_function :GDALGetPaletteInterpretationName, [PaletteInterp], :strptr

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # General stuff
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attach_function :GDALGetDataTypeSize, [DataType], :int
      attach_function :GDALDataTypeIsComplex, [DataType], :bool
      attach_function :GDALGetDataTypeName, [DataType], :strptr
      attach_function :GDALGetDataTypeByName, [:string], DataType
      attach_function :GDALDataTypeUnion, [DataType, DataType], DataType

      attach_function :GDALSetCacheMax, %i[int], :void
      attach_function :GDALSetCacheMax64, [CPL::Port.find_type(:GIntBig)], :void
      attach_function :GDALGetCacheMax, [], :int
      attach_function :GDALGetCacheMax64, [], CPL::Port.find_type(:GIntBig)
      attach_function :GDALGetCacheUsed, [], :int
      attach_function :GDALGetCacheUsed64, [], CPL::Port.find_type(:GIntBig)
      attach_function :GDALFlushCacheBlock, [], :bool

      attach_function :GDALLoadWorldFile, %i[string pointer], :bool
      attach_function :GDALReadWorldFile, %i[string string pointer], :bool
      attach_function :GDALWriteWorldFile, %i[string string pointer], :bool

      attach_function :GDALPackedDMSToDec, %i[double], :double
      attach_function :GDALDecToPackedDMS, %i[double], :double

      attach_function :GDALGeneralCmdLineProcessor, %i[int pointer int], :int
      attach_function :GDALSwapWords,
                      %i[pointer int int int],
                      :void
      attach_function :GDALCopyWords,
                      %i[pointer int int pointer int int int int],
                      :void
      attach_function :GDALCopyBits,
                      %i[pointer int int pointer int int int int],
                      :void
    end
  end
end
