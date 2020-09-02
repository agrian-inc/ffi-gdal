# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module CPL
    module VSI
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Defines
      #------------------------------------------------------------------------
      STAT_EXISTS_FLAG = 0x1
      STAT_NATURE_FLAG = 0x2
      STAT_SIZE_FLAG = 0x4

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef ::FFI::CPL::Port.find_type(:GUIntBig), :vsi_l_offset
      callback :VSIWriteFunction, %i[pointer size_t size_t pointer], :pointer

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :VSIFOpen, %i[string string], :pointer
      attach_function :VSIFClose, %i[pointer], :int
      attach_function :VSIFSeek, %i[pointer long int], :int
      attach_function :VSIFTell, %i[pointer], :long
      attach_function :VSIRewind, %i[pointer], :void
      attach_function :VSIFFlush, %i[pointer], :void
      attach_function :VSIFRead, %i[pointer size_t size_t pointer], :size_t
      attach_function :VSIFWrite, %i[pointer size_t size_t pointer], :size_t
      attach_function :VSIFGets, %i[pointer int pointer], :string
      attach_function :VSIFPuts, %i[string pointer], :int
      attach_function :VSIFPrintf, %i[pointer string varargs], :int
      attach_function :VSIFGetc, %i[pointer], :int
      attach_function :VSIFPutc, %i[int pointer], :int

      attach_function :VSIUngetc, %i[int pointer], :int
      attach_function :VSIFEof, %i[pointer], :int
      attach_function :VSIStat, %i[string pointer], :int

      attach_function :VSIFOpenL, %i[string string], :pointer
      attach_function :VSIFCloseL, %i[pointer], :int
      attach_function :VSIFSeekL, %i[pointer vsi_l_offset int], :int
      attach_function :VSIFTellL, %i[pointer], :vsi_l_offset
      attach_function :VSIRewindL, %i[pointer], :void
      attach_function :VSIFReadL, %i[pointer size_t size_t pointer], :size_t
      attach_function :VSIFReadMultiRangeL,
                      %i[int pointer pointer pointer pointer],
                      :int
      attach_function :VSIFWriteL, %i[pointer size_t size_t pointer], :size_t
      attach_function :VSIFEofL, %i[pointer], :int
      attach_function :VSIFTruncateL, %i[pointer vsi_l_offset], :int
      attach_function :VSIFFlushL, %i[pointer], :int
      attach_function :VSIFPrintfL, %i[pointer string varargs], :int
      attach_function :VSIFPutcL, %i[int pointer], :int
      attach_function :VSIIngestFile,
                      [:pointer, :string, :pointer, :pointer, Port.find_type(:GIntBig)],
                      :int
      attach_function :VSIStatL, %i[string pointer], :int
      attach_function :VSIStatExL, %i[string pointer int], :int

      attach_function :VSIIsCaseSensitiveFS, %i[string], :int
      attach_function :VSIFGetNativeFileDescriptorL, %i[pointer], :pointer

      attach_function :VSICalloc, %i[size_t size_t], :pointer
      attach_function :VSIMalloc, %i[size_t], :pointer
      attach_function :VSIFree, %i[pointer], :void
      attach_function :VSIRealloc, %i[pointer size_t], :pointer
      attach_function :VSIStrdup, %i[string], :strptr
      attach_function :VSIMalloc2, %i[size_t size_t], :pointer
      attach_function :VSIMalloc3, %i[size_t size_t size_t], :pointer

      attach_function :VSIReadDir, %i[string], :pointer
      attach_function :VSIReadDirRecursive, %i[string], :pointer
      attach_function :VSIMkdir, %i[string long], :int
      attach_function :VSIRmdir, %i[string], :int
      attach_function :VSIUnlink, %i[string], :int
      attach_function :VSIRename, %i[string string], :int

      attach_function :VSIStrerror, %i[int], :strptr

      attach_function :VSIInstallMemFileHandler, [], :void
      attach_function :VSIInstallLargeFileHandler, [], :void
      attach_function :VSIInstallSubFileHandler, [], :void
      attach_function :VSIInstallCurlFileHandler, [], :void
      attach_function :VSIInstallCurlStreamingFileHandler, [], :void
      attach_function :VSIInstallGZipFileHandler, [], :void
      attach_function :VSIInstallZipFileHandler, [], :void
      attach_function :VSIInstallStdinHandler, [], :void
      attach_function :VSIInstallStdoutHandler, [], :void
      attach_function :VSIInstallSparseFileHandler, [], :void
      attach_function :VSIInstallTarFileHandler, [], :void
      attach_function :VSICleanupFileManager, [], :void

      attach_function :VSIFileFromMemBuffer,
                      %i[string pointer vsi_l_offset int],
                      :pointer
      attach_function :VSIGetMemFileBuffer,
                      %i[string pointer int],
                      :pointer
      attach_function :VSIStdoutSetRedirection,
                      %i[VSIWriteFunction pointer],
                      :pointer

      attach_function :VSITime, %i[pointer], :ulong
      attach_function :VSICTime, %i[ulong], :strptr
      attach_function :VSIGMTime, %i[pointer pointer], :pointer
      attach_function :VSILocalTime, %i[pointer pointer], :pointer
    end
  end
end
