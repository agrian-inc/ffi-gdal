# typed: true
# frozen_string_literal: true

require_relative 'exceptions'

module OGR
  # OGR returns errors as Integers--not as part of the GDAL/CPLErr error
  # handling callback interface.  This hacks together a facility for sort of
  # doing that with OGR.
  #
  # Unlike the OGR API, ffi-gdal defines an Enum for the OGRERR types, which
  # in turns causes OGR to return Symbols on errors (the #defines for those can
  # be found here: http://www.gdal.org/ogr__core_8h.html).  This maps those
  # Symbols to Ruby exceptions (or lack thereof).
  module ErrorHandling
    ERROR_CLASS_MAP = {
      OGRERR_NONE: nil,
      OGRERR_NOT_ENOUGH_DATA: OGR::NotEnoughData,
      OGRERR_NOT_ENOUGH_MEMORY: ::NoMemoryError,
      OGRERR_UNSUPPORTED_GEOMETRY_TYPE: OGR::UnsupportedGeometryType,
      OGRERR_UNSUPPORTED_OPERATION: OGR::UnsupportedOperation,
      OGRERR_CORRUPT_DATA: OGR::CorruptData,
      OGRERR_FAILURE: OGR::Failure,
      OGRERR_UNSUPPORTED_SRS: OGR::UnsupportedSRS,
      OGRERR_INVALID_HANDLE: OGR::InvalidHandle
    }.freeze

    # Yields, then expects the result to be a Symbol from FFI::OGR::Core::Err.
    #
    # @param msg [String]
    def self.handle_ogr_err(msg)
      ogr_err_symbol = yield

      klass = ERROR_CLASS_MAP.fetch(ogr_err_symbol) { raise "Unknown OGRERR type: #{self}" }

      raise_exception(klass, msg) if klass
    end

    # Exists solely to strip off the top 4 lines of the backtrace so it doesn't
    # look like the problem is coming from here.
    def self.raise_exception(exception, message)
      e = exception.new(message)
      e.set_backtrace(caller(2))
      raise(e)
    end
  end
end
