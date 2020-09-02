# typed: true
# frozen_string_literal: true

require 'ffi'

module FFI
  module OGR
    module Featurestyle
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      StyleType = enum :OGRSTypeString,
                       :OGRSTypeDouble,
                       :OGRSTypeInteger,
                       :OGRSTypeBoolean

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      SType = StyleType
      StyleParamId = FFI::OGR::StyleParam
    end
  end
end
