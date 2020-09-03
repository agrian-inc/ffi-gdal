# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module GDAL
  class ColorInterpretation
    extend T::Sig

    # @param gdal_color_interp [FFI::Enum] A FFI::GDAL::GDAL::ColorInterp.
    # @return [String]
    sig { params(gdal_color_interp: FFI::Enum).returns(String) }
    def self.name(gdal_color_interp)
      # The returned strings are static strings and should not be modified or freed by the application.
      name, ptr = FFI::GDAL::GDAL.GDALGetColorInterpretationName(gdal_color_interp)
      ptr.autorelease = false

      name
    end

    # @param name [String]
    # @return [FFI::Enum] A FFI::GDAL::GDAL::ColorInterp.
    sig { params(name: String).returns(FFI::Enum) }
    def self.by_name(name)
      FFI::GDAL::GDAL.GDALGetColorInterpretationByName(name)
    end
  end
end
