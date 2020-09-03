# typed: true
# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module CPL
    module Progress
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_function :GDALCreateScaledProgress,
                      [:double, :double, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                      :pointer
      attach_function :GDALDestroyScaledProgress,
                      %i[pointer],
                      :void
      ScaledProgress = attach_function :GDALScaledProgress,
                                       %i[double string pointer],
                                       :bool
      TermProgress = attach_function :GDALTermProgress,
                                     %i[double string pointer],
                                     :bool
    end
  end
end
