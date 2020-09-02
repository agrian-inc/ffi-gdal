# typed: false
# frozen_string_literal: true

require 'ffi'
require 'ffi/library'

module FFI
  # Redefining #attach_function so we can avoid bombing out if a called method
  # is not defined.
  module Library
    alias old_attach_function attach_function

    def attach_function(*args)
      old_attach_function(*args)
    rescue FFI::NotFoundError
      @unsupported_gdal_functions ||= []

      if $VERBOSE || ENV['VERBOSE']
        warn "ffi-gdal warning: function '#{args.first}' is not available in this " \
          "build of GDAL/OGR (v#{FFI::GDAL.GDALVersionInfo('RELEASE_NAME')})"
      end

      @unsupported_gdal_functions << args.first
    end

    def unsupported_gdal_functions
      @unsupported_gdal_functions ||= []
    end
  end
end
