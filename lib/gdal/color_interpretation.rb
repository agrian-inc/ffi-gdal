# typed: true
# frozen_string_literal: true

module GDAL
  class ColorInterpretation
    # @param gdal_color_interp [FFI::GDAL::GDAL::ColorInterp]
    # @return [String]
    def self.name(gdal_color_interp)
      # The returned strings are static strings and should not be modified or freed by the application.
      name, ptr = FFI::GDAL::GDAL.GDALGetColorInterpretationName(gdal_color_interp)
      ptr.autorelease = false

      name
    end

    # @param name [String]
    # @return [FFI::GDAL::GDAL::ColorInterp]
    def self.by_name(name)
      FFI::GDAL::GDAL.GDALGetColorInterpretationByName(name)
    end
  end
end
