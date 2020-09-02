# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module CPL
    module HashSet
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #-------------------------------------------------------------------------
      # Typedefs
      #-------------------------------------------------------------------------
      callback :CPLHashSetHashFunc, %i[pointer], :ulong
      callback :CPLHashSetEqualFunc, %i[pointer pointer], :bool
      callback :CPLHashSetFreeEltFunc, %i[pointer], :void
      callback :CPLHashSetIterEltFunc, %i[pointer pointer], :int
      typedef :pointer, :CPLHashSetH

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_function :CPLHashSetNew,
                      %i[CPLHashSetHashFunc CPLHashSetEqualFunc CPLHashSetFreeEltFunc],
                      :CPLHashSetH
      attach_function :CPLHashSetDestroy, %i[CPLHashSetH], :void
      attach_function :CPLHashSetSize, %i[CPLHashSetH], :int
      attach_function :CPLHashSetForeach,
                      %i[CPLHashSetH CPLHashSetIterEltFunc pointer],
                      :void
      attach_function :CPLHashSetInsert, %i[CPLHashSetH pointer], :bool
      attach_function :CPLHashSetLookup, %i[CPLHashSetH pointer], :pointer
      attach_function :CPLHashSetRemove, %i[CPLHashSetH pointer], :bool
      attach_function :CPLHashSetHashPointer, %i[pointer], :ulong
      attach_function :CPLHashSetEqualPointer, %i[pointer pointer], :bool
      attach_function :CPLHashSetHashStr, %i[string], :ulong
      attach_function :CPLHashSetEqualStr, %i[string string], :bool
    end
  end
end
