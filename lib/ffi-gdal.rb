# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative 'ext/ffi_library_function_checks'
require_relative 'ext/narray_ext'
require_relative 'ext/numeric_as_data_type'
require_relative 'ext/float_ext'

module FFI
  autoload :CPL, File.expand_path('ffi/cpl.rb', __dir__)
  autoload :GDAL, File.expand_path('ffi/gdal.rb', __dir__)
  autoload :OGR, File.expand_path('ffi/ogr.rb', __dir__)
end
