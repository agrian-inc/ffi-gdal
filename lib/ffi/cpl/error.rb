# typed: true
# frozen_string_literal: true

require_relative '../../ext/ffi_library_function_checks'

module FFI
  module CPL
    module Error
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      CPLErr = enum :CE_None, 0,
                    :CE_Debug, 1,
                    :CE_Warning, 2,
                    :CE_Failure, 3,
                    :CE_Fatal, 4

      callback :CPLErrorHandler, [CPLErr, :int, :string], :void

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :CPLError, [CPLErr, :int, :string], :void
      attach_function :CPLErrorV, [CPLErr, :int, :string, :pointer], :void
      attach_function :CPLEmergencyError, [], :void
      attach_function :CPLErrorReset, [], :void

      attach_function :CPLGetLastErrorNo, [], :int
      attach_function :CPLGetLastErrorType, [], CPLErr
      attach_function :CPLGetLastErrorMsg, [], :strptr

      attach_function :CPLGetErrorHandlerUserData, [], :pointer
      attach_function :CPLCleanupErrorMutex, [], :void
      attach_function :CPLLoggingErrorHandler,
                      [CPLErr, :int, :string],
                      :void
      attach_function :CPLDefaultErrorHandler,
                      [CPLErr, :int, :string],
                      :void
      attach_function :CPLQuietErrorHandler,
                      [CPLErr, :int, :string],
                      :void
      attach_function :CPLTurnFailureIntoWarning, [:int], :void

      attach_function :CPLSetErrorHandler,
                      [:CPLErrorHandler],
                      :CPLErrorHandler
      attach_function :CPLSetErrorHandlerEx,
                      %i[CPLErrorHandler pointer],
                      :CPLErrorHandler
      attach_function :CPLPushErrorHandler,
                      [:CPLErrorHandler],
                      :void
      attach_function :CPLPushErrorHandlerEx,
                      %i[CPLErrorHandler pointer],
                      :void
      attach_function :CPLPopErrorHandler, [], :void

      attach_function :CPLDebug, %i[string string], :void
      attach_function :_CPLAssert, %i[string string int], :void
    end
  end
end
