# typed: true
# frozen_string_literal: true

require_relative 'ffi-gdal'

module GDAL
  class << self
    # Use when you want something quick and easy for when you need something
    # quick for a +FFI::GDAL::GDALProgressFunc+. Outputs the duration and
    # percentage completed.
    #
    # @return [Proc] A Proc that works for a +GDALProgressFunc+ callback.
    def simple_progress_formatter
      start = Time.now

      lambda do |d, _, _|
        print "Duration: #{(Time.now - start).to_f.round(2)}s\t| #{(d * 100).round(2)}%\r"
        true
      end
    end

    private

    def gdal_require(path)
      File.expand_path(path, __dir__)
    end
  end

  # Autoload just the core GDAL object types.
  autoload :ColorTable,           gdal_require('gdal/color_table')
  autoload :Dataset,              gdal_require('gdal/dataset')
  autoload :DataType,             gdal_require('gdal/data_type')
  autoload :Driver,               gdal_require('gdal/driver')
  autoload :GeoTransform,         gdal_require('gdal/geo_transform')
  autoload :Logger,               gdal_require('gdal/logger')
  autoload :MajorObject,          gdal_require('gdal/major_object')
  autoload :Options,              gdal_require('gdal/options')
  autoload :RasterAttributeTable, gdal_require('gdal/raster_attribute_table')
  autoload :RasterBand,           gdal_require('gdal/raster_band')
end

require_relative 'gdal/exceptions'
require_relative 'gdal/version_info'
require_relative 'gdal/environment_methods'
require_relative 'gdal/internal_helpers'
require_relative 'gdal/cpl_error_handler'

module GDAL
  extend VersionInfo
  extend EnvironmentMethods
  include InternalHelpers

  # Register all drivers!
  ::FFI::GDAL::GDAL.GDALAllRegister

  # We define our own error handler so we can turn GDAL errors into Ruby
  # exceptions.
  FFI_GDAL_ERROR_HANDLER = GDAL::CPLErrorHandler.handle_error
  ::FFI::CPL::Error.CPLSetErrorHandler(FFI_GDAL_ERROR_HANDLER)
end
