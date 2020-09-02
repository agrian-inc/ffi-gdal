# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module CPL
    module Port
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :int, :GInt32
      typedef :uint, :GUInt32
      typedef :short, :GInt16
      typedef :ushort, :GUInt16
      typedef :uchar, :GByte
      typedef :int, :GBool
      typedef :long_long, :GIntBig
      typedef :ulong_long, :GUIntBig
      typedef :GIntBig, :GPtrDiff_t
    end
  end
end
