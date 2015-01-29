require_relative 'exceptions'

module GDAL
  # This is used to override GDAL's built-in error handling.  By default, GDAL
  # only logs errors to STDOUT, which doesn't allow a whole lot of flexibility.
  # This maps GDAL's errors to either standard Ruby exceptions or new exceptions
  # defined in this gem.  Doing so also lets ffi-gdal users rescue these
  # exceptions, which is beneficial for obvious reasons.
  class CPLErrorHandler
    include GDAL::Logger

    CPLE_MAP = [
      { cple: :CPLE_None, exception: nil },
      { cple: :CPLE_AppDefined, exception: nil },
      { cple: :CPLE_OutOfMemory, exception: ::NoMemoryError },
      { cple: :CPLE_FileIO, exception: ::IOError },
      { cple: :CPLE_OpenFailed, exception: GDAL::OpenFailure },
      { cple: :CPLE_IllegalArg, exception: ::ArgumentError },
      { cple: :CPLE_NotSupported, exception: GDAL::UnsupportedOperation },
      { cple: :CPLE_AssertionFailed, exception: ::RuntimeError },
      { cple: :CPLE_NoWriteAccess, exception: GDAL::NoWriteAccess },
      { cple: :CPLE_UserInterrupt, exception: ::Interrupt },
      { cple: :CPLE_ObjectNull, exception: GDAL::NullObject }
    ]

    FAIL_PROC = lambda do |exception, message|
      ex = exception ? exception.new(message) : GDAL::Error.new(message)
      ex.set_backtrace(caller(4))

      fail(ex)
    end

    SUCCESS_PROC = proc { true }

    # @return [Proc]
    def self.handle_error
      new.handler_lambda
    end

    # @return [Proc]
    attr_accessor :on_none

    # @return [Proc]
    attr_accessor :on_debug

    # @return [Proc]
    attr_accessor :on_warning

    # @return [Proc]
    attr_accessor :on_failure

    # @return [Proc]
    attr_accessor :on_fatal

    def initialize
      @on_none = SUCCESS_PROC
      @on_debug = SUCCESS_PROC
      @on_warning = ->(_, message) { warn(message); false }
      @on_failure = FAIL_PROC
      @on_fatal = FAIL_PROC
    end

    # Looks up the error class then calls the appropriate +on_+ proc, thus
    # handling various error/non-error scenarios.  More info here:
    # http://www.gdal.org/cpl__error_8h.html#a74d0e649d58180e621540bf73b58e4a2.
    #
    # @return [Proc] A lambda that adheres to the CPL Error interface.
    def handler_lambda
      @handler_lambda ||= lambda do |error_class, error_number, message|
        result(error_class, error_number, message)
      end
    end

    # Use this when you want to override the default event handling.  For
    # example, you may want to return a value in the case of a :CE_Warning.
    # To do so, you need to create a new ErrorHandler object, assign a new
    # Proc by calling #on_warning=, then call this method with your wrapped
    # CPLErr-returning function in a block.  That might look something like:
    #
    #     handler = GDAL::ErrorHandler.new
    #     handler.on_warning = -> { warn 'Uh oh!'; return Array.new }
    #     handler.custom_handle do
    #       FFI::GDAL.DoSomeStuff()
    #     end
    #
    # After this code gets called, error handling will return to normal.
    def custom_handle
      FFI::GDAL.CPLPushErrorHandler(handler_lambda)
      yield
      FFI::GDAL.CPLPopErrorHandler

      result(FFI::GDAL.CPLGetLastErrorType,
             FFI::GDAL.CPLGetLastErrorNo,
             FFI::GDAL.CPLGetLastErrorMsg
      )
    end

    private

    # @return Whatever the Proc evaluates.
    def result(error_class, error_number, message)
      error_class_map(error_class).call(CPLE_MAP[error_number][:exception], message)
    end

    def error_class_map(error_class)
      {
        CE_None: @on_none,
        CE_Debug: @on_debug,
        CE_Warning: @on_warning,
        CE_Failure: @on_failure,
        CE_Fatal: @on_fatal
      }[error_class]
    end
  end
end
