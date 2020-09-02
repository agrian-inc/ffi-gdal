# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module CPL
    module Conv
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      callback :CPLFileFinder, %i[string string], :pointer

      #---------
      # Config
      #---------
      attach_function :CPLVerifyConfiguration, %i[], :void
      attach_function :CPLGetConfigOption, %i[string string], :strptr
      attach_function :CPLSetConfigOption, %i[string string], :void
      attach_function :CPLSetThreadLocalConfigOption, %i[string string], :void
      attach_function :CPLFreeConfig, %i[], :void

      #---------
      # Memory
      #---------
      attach_function :CPLMalloc, %i[size_t], :pointer
      attach_function :CPLCalloc, %i[size_t size_t], :pointer
      attach_function :CPLRealloc, %i[pointer size_t], :pointer

      #---------
      # Strings
      #---------
      attach_function :CPLStrdup, %i[string], :string
      attach_function :CPLStrlwr, %i[string], :string
      attach_function :CPLFGets, %i[string int pointer], :string
      attach_function :CPLReadLine, %i[pointer], :strptr
      attach_function :CPLReadLineL, %i[pointer], :strptr
      attach_function :CPLReadLine2L, %i[pointer int pointer], :strptr
      attach_function :CPLAtof, %i[string], :double
      attach_function :CPLAtofDelim, %i[string char], :double
      attach_function :CPLStrtod, %i[string pointer], :double
      attach_function :CPLStrtodDelim, %i[string pointer char], :double
      attach_function :CPLStrtof, %i[string pointer], :float
      attach_function :CPLStrtofDelim, %i[string pointer char], :float
      attach_function :CPLAtofM, %i[string], :double
      # Caller responsible to free this buffer with CPLFree().
      attach_function :CPLScanString, %i[string int int int], :pointer
      attach_function :CPLScanDouble, %i[string int], :double
      attach_function :CPLScanLong, %i[string int], :long
      attach_function :CPLScanULong, %i[string int], :ulong
      attach_function :CPLScanUIntBig, %i[string int], Port.find_type(:GUIntBig)
      attach_function :CPLScanPointer, %i[string int], :pointer
      attach_function :CPLPrintString, %i[string string int], :int
      attach_function :CPLPrintStringFill, %i[string string int], :int

      #---------
      # Numbers to strings
      #---------
      attach_function :CPLPrintInt32, [:string, Port.find_type(:GInt32), :int], :int
      attach_function :CPLPrintUIntBig, [:string, Port.find_type(:GUIntBig), :int], :int
      attach_function :CPLPrintDouble, %i[string string double string], :int
      attach_function :CPLPrintTime, %i[string int string pointer string], :int
      attach_function :CPLPrintPointer, %i[string pointer int], :int
      attach_function :CPLGetSymbol, %i[string string], :pointer

      #---------
      # Files
      #---------
      attach_function :CPLGetExecPath, %i[string int], :int
      attach_function :CPLGetPath, %i[string], :strptr
      attach_function :CPLGetDirname, %i[string], :strptr
      attach_function :CPLGetFilename, %i[string], :strptr
      attach_function :CPLGetBasename, %i[string], :strptr
      attach_function :CPLGetExtension, %i[string], :strptr
      # User is responsible to free that buffer after usage with CPLFree() function.
      attach_function :CPLGetCurrentDir, [], :pointer
      attach_function :CPLFormFilename, %i[string string string], :strptr
      attach_function :CPLFormCIFilename, %i[string string string], :strptr
      attach_function :CPLResetExtension, %i[string string], :strptr
      attach_function :CPLProjectRelativeFilename, %i[string string], :strptr
      attach_function :CPLIsFilenameRelative, %i[string], :int
      attach_function :CPLExtractRelativePath, %i[string string pointer], :strptr
      attach_function :CPLCleanTrailingSlash, %i[string], :strptr
      attach_function :CPLCorrespondingPaths, %i[string string pointer], :pointer
      attach_function :CPLCheckForFile, %i[string string], :int
      attach_function :CPLGenerateTempFilename, %i[string], :strptr
      attach_function :CPLFindFile, %i[string string], :strptr
      attach_function :CPLDefaultFindFile, %i[string string], :strptr
      attach_function :CPLPushFileFinder, %i[CPLFileFinder], :void
      attach_function :CPLPopFileFinder, %i[], :CPLFileFinder
      attach_function :CPLPushFinderLocation, %i[string], :void
      attach_function :CPLPopFinderLocation, %i[], :void
      attach_function :CPLFinderClean, %i[], :void
      attach_function :CPLStat, %i[string pointer], :int
      attach_function :CPLOpenShared, %i[string string bool], :pointer
      attach_function :CPLCloseShared, %i[pointer], :void
      attach_function :CPLGetSharedList, %i[pointer], :pointer
      attach_function :CPLDumpSharedList, %i[pointer], :void
      attach_function :CPLCleanupSharedFileMutex, %i[], :void

      attach_function :CPLDMSToDec, %i[string], :double
      attach_function :CPLDecToDMS, %i[double string int], :string
      attach_function :CPLPackedDMSToDec, %i[double], :double
      attach_function :CPLDecToPackedDMS, %i[double], :string
      attach_function :CPLStringToComplex, %i[string pointer pointer], :void
      attach_function :CPLUnlinkTree, %i[string], :int
      attach_function :CPLCopyFile, %i[string string], :int
      attach_function :CPLMoveFile, %i[string string], :int

      #---------
      # Zip Files
      #---------
      attach_function :CPLCreateZip, %i[string pointer], :pointer
      attach_function :CPLCreateFileInZip, %i[pointer string pointer], FFI::CPL::Error::CPLErr
      attach_function :CPLWriteFileInZip, %i[pointer pointer int], FFI::CPL::Error::CPLErr
      attach_function :CPLCloseFileInZip, %i[pointer], FFI::CPL::Error::CPLErr
      attach_function :CPLCloseZip, %i[pointer], FFI::CPL::Error::CPLErr
      attach_function :CPLZLibDeflate,
                      %i[pointer size_t int pointer size_t pointer],
                      :pointer
      attach_function :CPLZLibInflate,
                      %i[pointer size_t pointer size_t pointer],
                      :pointer

      attach_function :CPLValidateXML, %i[string string pointer], :int
      attach_function :CPLsetlocale, %i[int string], :strptr

      attach_function :CPLCleanupSetlocaleMutex, %i[], :void
    end
  end
end
