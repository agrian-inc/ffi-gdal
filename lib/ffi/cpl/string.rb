# typed: true
# frozen_string_literal: true

require_relative '../../ext/ffi_library_function_checks'

module FFI
  module CPL
    module String
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :string, :CPLString

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      ValueType = enum :CPL_VALUE_STRING,
                       :CPL_VALUE_REAL,
                       :CPL_VALUE_INTEGER

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :CSLAddString, %i[pointer string], :pointer
      attach_function :CSLCount, %i[pointer], :int
      attach_function :CSLGetField, %i[pointer int], :strptr
      attach_function :CSLDestroy, %i[pointer], :void
      attach_function :CSLDuplicate, %i[pointer], :pointer
      attach_function :CSLMerge, %i[pointer pointer], :pointer
      attach_function :CSLTokenizeString, %i[string], :pointer
      attach_function :CSLTokenizeStringComplex,
                      %i[string string int int],
                      :pointer
      attach_function :CSLTokenizeString2, %i[string string int], :pointer
      attach_function :CSLPrint, %i[pointer pointer], :int
      attach_function :CSLLoad, %i[string], :pointer
      attach_function :CSLLoad2, %i[string int int pointer], :pointer
      attach_function :CSLSave, %i[pointer string], :int
      attach_function :CSLInsertStrings, %i[pointer int pointer], :pointer
      attach_function :CSLInsertString, %i[pointer int string], :pointer
      attach_function :CSLRemoveStrings, %i[pointer int int pointer], :pointer
      attach_function :CSLFindString, %i[pointer string], :int
      attach_function :CSLPartialFindString, %i[pointer string], :int
      attach_function :CSLFindName, %i[pointer string], :int

      attach_function :CSLTestBoolean, %i[string], :int
      attach_function :CSLFetchBoolean, %i[pointer string int], :int

      attach_function :CPLParseNameValue, %i[string pointer], :strptr
      attach_function :CSLFetchNameValue, %i[pointer string], :strptr
      attach_function :CSLFetchNameValueDef, %i[pointer string string], :strptr
      attach_function :CSLFetchNameValueMultiple, %i[pointer string], :pointer
      attach_function :CSLAddNameValue, %i[pointer string string], :pointer
      attach_function :CSLSetNameValue, %i[pointer string string], :pointer
      attach_function :CSLSetNameValueSeparator, %i[pointer string], :void

      attach_function :CPLEscapeString, %i[string int int], :strptr
      attach_function :CPLUnescapeString, %i[string pointer int], :strptr
      attach_function :CPLBinaryToHex, %i[int pointer], :strptr
      attach_function :CPLHexToBinary, %i[string pointer], :pointer
      attach_function :CPLBase64Encode, %i[int pointer], :strptr
      attach_function :CPLBase64DecodeInPlace, %i[pointer], :int

      attach_function :CPLGetValueType, %i[string], ValueType
      attach_function :CPLStrlcpy, %i[string string size_t], :size_t
      attach_function :CPLStrlcat, %i[string string size_t], :size_t
      attach_function :CPLStrnlen, %i[string size_t], :size_t
      attach_function :CPLSPrintf, %i[string varargs], :string
      attach_function :CSLAppendPrintf, %i[pointer string varargs], :pointer
      attach_function :CPLVASPrintf, %i[pointer string varargs], :pointer

      attach_function :CPLEncodingCharSize, %i[string], :int

      attach_function :CPLClearRecodeWarningFlags, [], :void
      attach_function :CPLRecode, %i[string string string], :strptr
      attach_function :CPLRecodeFromWChar, %i[string string string], :strptr
      attach_function :CPLRecodeToWChar, %i[string string string], :strptr

      attach_function :CPLIsUTF8, %i[string int], :bool
      attach_function :CPLForceToASCII, %i[string int char], :strptr
      attach_function :CPLStrlenUTF8, %i[string], :int
    end
  end
end
