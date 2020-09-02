# typed: false
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative 'field'

module FFI
  module OGR
    module Core
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      # The C API defines :OGRErr as a function that returns constants.  I'm
      # taking the liberty to turn this into an enum.
      # https://trac.osgeo.org/gdal/ticket/3153
      Err = enum :OGRERR_NONE,
                 :OGRERR_NOT_ENOUGH_DATA,
                 :OGRERR_NOT_ENOUGH_MEMORY,
                 :OGRERR_UNSUPPORTED_GEOMETRY_TYPE,
                 :OGRERR_UNSUPPORTED_OPERATION,
                 :OGRERR_CORRUPT_DATA,
                 :OGRERR_FAILURE,
                 :OGRERR_UNSUPPORTED_SRS,
                 :OGRERR_INVALID_HANDLE

      WKBGeometryType = enum FFI::Type::UINT,
                             :wkbUnknown,                0,
                             :wkbPoint,                  1,
                             :wkbLineString,             2,
                             :wkbPolygon,                3,
                             :wkbMultiPoint,             4,
                             :wkbMultiLineString,        5,
                             :wkbMultiPolygon,           6,
                             :wkbGeometryCollection,     7,
                             :wkbNone,                   100,    # non-standard, for pure attribute records
                             :wkbLinearRing,             101,    # non-standard, just for createGeometry
                             :wkbPoint25D,               0x8000_0001,
                             :wkbLineString25D,          0x8000_0002,
                             :wkbPolygon25D,             0x8000_0003,
                             :wkbMultiPoint25D,          0x8000_0004,
                             :wkbMultiLineString25D,     0x8000_0005,
                             :wkbMultiPolygon25D,        0x8000_0006,
                             :wkbGeometryCollection25D,  0x8000_0007

      WKBVariant = enum :wkbVariantOgc, :wkbVariantIso
      WKBByteOrder = enum :wkbXDR, 0,
                          :wkbNDR, 1

      FieldType = enum :OFTInteger, 0,
                       :OFTIntegerList,     1,
                       :OFTReal,            2,
                       :OFTRealList,        3,
                       :OFTString,          4,
                       :OFTStringList,      5,
                       :OFTWideString,      6,
                       :OFTWideStringList,  7,
                       :OFTBinary,          8,
                       :OFTDate,            9,
                       :OFTTime,            10,
                       :OFTDateTime,        11,
                       :OFTInteger64,       12,
                       :OFTInteger64List,   13,
                       :OFTMaxType,         13

      FieldSubType = enum :OFSTNone,
                          :OFSTBoolean,
                          :OFSTInt16,
                          :OFSTFloat32

      Justification = enum :OJUndefined, 0,
                           :OJLeft,   1,
                           :OJRight,  2

      STClassId = enum :OGRSTCNone, 0,
                       :OGRSTCPen,     1,
                       :OGRSTCBrush,   2,
                       :OGRSTCSymbol,  3,
                       :OGRSTCLabel,   4,
                       :OGRSTCVector,  5

      STUnitId = enum :OGRSTUGround, 0,
                      :OGRSTUPixel,   1,
                      :OGRSTUPoints,  2,
                      :OGRSTUMM,      3,
                      :OGRSTUCM,      4,
                      :OGRSTUInches,  5

      STPenParam = enum :OGRSTPenColor, 0,
                        :OGRSTPenWidth,       1,
                        :OGRSTPenPattern,     2,
                        :OGRSTPenId,          3,
                        :OGRSTPenPerOffset,   4,
                        :OGRSTPenPerCap,      5,
                        :OGRSTPenPerJoin,     6,
                        :OGRSTPenPerPriority, 7,
                        :OGRSTPenLast,        8

      STBrushParam = enum :OGRSTBrushFColor, 0,
                          :OGRSTBrushBColor,    1,
                          :OGRSTBrushId,        2,
                          :OGRSTBrushAngle,     3,
                          :OGRSTBrushSize,      4,
                          :OGRSTBrushDx,        5,
                          :OGRSTBrushDy,        6,
                          :OGRSTBrushPriority,  7,
                          :OGRSTBrushLast,      8

      STSymbolParam = enum :OGRSTSymbolId, 0,
                           :OGRSTSymbolAngle,     1,
                           :OGRSTSymbolColor,     2,
                           :OGRSTSymbolSize,      3,
                           :OGRSTSymbolDx,        4,
                           :OGRSTSymbolDy,        5,
                           :OGRSTSymbolStep,      6,
                           :OGRSTSymbolPerp,      7,
                           :OGRSTSymbolOffset,    8,
                           :OGRSTSymbolPriority,  9,
                           :OGRSTSymbolFontName, 10,
                           :OGRSTSymbolOColor,   11,
                           :OGRSTSymbolLast,      12

      STLabelParam = enum :OGRSTLabelFontName, 0,
                          :OGRSTLabelSize,        1,
                          :OGRSTLabelTextString,  2,
                          :OGRSTLabelAngle,       3,
                          :OGRSTLabelFColor,      4,
                          :OGRSTLabelBColor,      5,
                          :OGRSTLabelPlacement,   6,
                          :OGRSTLabelAnchor,      7,
                          :OGRSTLabelDx,          8,
                          :OGRSTLabelDy,          9,
                          :OGRSTLabelPerp,        10,
                          :OGRSTLabelBold,        11,
                          :OGRSTLabelItalic,      12,
                          :OGRSTLabelUnderline,   13,
                          :OGRSTLabelPriority,    14,
                          :OGRSTLabelStrikeout,   15,
                          :OGRSTLabelStretch,     16,
                          :OGRSTLabelAdjHor,      17,
                          :OGRSTLabelAdjVert,     18,
                          :OGRSTLabelHColor,      19,
                          :OGRSTLabelOColor,      20,
                          :OGRSTLabelLast,        21

      #------------------------------------------------------------------------
      # Constants
      #------------------------------------------------------------------------
      OGR_ALTER = FFI::ConstGenerator.new do |gen|
        gen.include FFI::GDAL._file_with_constants('ogr_core.h')
        gen.const :ALTER_NAME_FLAG, '%x'
        gen.const :ALTER_TYPE_FLAG, '%x'
        gen.const :ALTER_WIDTH_PRECISION_FLAG, '%x'
        gen.const :ALTER_ALL_FLAG, '%x'
      end
      OGR_ALTER.calculate

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :int, :OGRBoolean

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :OGRMalloc, [:size_t], :pointer
      attach_function :OGRCalloc, %i[size_t size_t], :pointer
      attach_function :OGRRealloc, %i[pointer size_t], :pointer
      attach_function :OGRFree, [:pointer], :void

      attach_function :OGRGeometryTypeToName, [WKBGeometryType], :strptr
      attach_function :OGRMergeGeometryTypes,
                      [WKBGeometryType, WKBGeometryType],
                      WKBGeometryType
      attach_function :OGRParseDate, [:string, FFI::OGR::Field.ptr, :int], :int
    end
  end
end
