# typed: true
# frozen_string_literal: true

class Float
  # Converts a packed DMS value (DDDMMMSSS.SS) into decimal degrees.
  #
  # @return [Float]
  def to_decimal_degrees
    FFI::GDAL::GDAL.GDALPackedDMSToDec(self)
  end

  # Converts decimal degrees int a packed DMS value (DDDMMMSSS.SS).
  #
  # @return [Float]
  def to_dms
    FFI::GDAL::GDAL.GDALDecToPackedDMS(self)
  end
end
