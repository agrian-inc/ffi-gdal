# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative 'http_result'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module CPL
    module HTTP
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_function :CPLHTTPEnabled, [], :bool
      attach_function :CPLHTTPFetch, %i[string pointer], HTTPResult.ptr
      attach_function :CPLHTTPCleanup, [], :void
      attach_function :CPLHTTPDestroyResult, [HTTPResult.ptr], :void
      attach_function :CPLHTTPParseMultipartMime, [HTTPResult.ptr], :bool

      attach_function :GOA2GetAuthorizationURL, %i[string], :strptr
      attach_function :GOA2GetRefreshToken, %i[string string], :strptr
      attach_function :GOA2GetAccessToken, %i[string string], :strptr
    end
  end
end
