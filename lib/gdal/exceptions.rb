# typed: true
# frozen_string_literal: true

module GDAL
  class BufferTooSmall < StandardError
  end

  class CreateFail < StandardError
  end

  class Error < ::RuntimeError
  end

  class OpenFailure < StandardError
    def initialize(file, msg = nil)
      message = msg || "Unable to open file '#{file}'. Perhaps an unsupported file format?"
      super(message)
    end
  end

  class InvalidAccessFlag < RuntimeError
  end

  class InvalidBandNumber < StandardError
  end

  class InvalidColorTable < StandardError
  end

  class InvalidDataType < StandardError
  end

  class InvalidDriverIndex < StandardError
  end

  class InvalidDriverName < StandardError
  end

  class InvalidGeoTransform < StandardError
  end

  class InvalidRasterBand < StandardError
  end

  # Used when a RasterBand erase operation can't find a value to use to set for
  # values to erase.
  class NoRasterEraseValue < RuntimeError
  end

  # Indicates that neither field attributes were selected nor Z fields were
  # provided to allow for gridding.
  class NoValuesToGrid < RuntimeError
  end

  class NoWriteAccess < RuntimeError
  end

  class NullObject < TypeError
  end

  class RequiredBandNotFound < StandardError
  end

  class UnknownGridAlgorithm < StandardError
    def initialize(algorithm, msg = nil)
      message = msg || "Unknown Grid algorithm type '#{algorithm}'."
      super(message)
    end
  end

  class UnknownRasterAttributeTableType < StandardError
  end

  class UnsupportedOperation < StandardError
  end
end
