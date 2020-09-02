# typed: true
# frozen_string_literal: true

module OGR
  class CorruptData < RuntimeError
  end

  class CreateFailure < RuntimeError
  end

  class DriverNotFound < RuntimeError
    def initialize(driver, msg = nil)
      message =
        if msg
          msg
        elsif driver.is_a? String
          "Driver not found with name '#{driver}'."
        elsif driver.is_a? Integer
          "Driver at index #{driver} not found."
        end

      super(message)
    end
  end

  class Failure < StandardError
  end

  class InvalidDataSource < StandardError
  end

  class InvalidFeature < StandardError
  end

  class InvalidFeatureDefinition < StandardError
  end

  class InvalidFieldDefinition < StandardError
  end

  class InvalidFieldName < StandardError
  end

  class InvalidGeometry < StandardError
  end

  class InvalidGeometryFieldDefinition < StandardError
  end

  class InvalidHandle < RuntimeError
  end

  class InvalidLayer < StandardError
  end

  class InvalidStyleTable < StandardError
  end

  class InvalidSpatialReference < StandardError
  end

  class NotEnoughData < RuntimeError
  end

  class OpenFailure < RuntimeError
    def initialize(file, msg = nil)
      message = msg || "Unable to open file '#{file}'. Perhaps an unsupported file format?"
      super(message)
    end
  end

  class ReadOnlyObject < StandardError
    def initialize(msg = nil)
      message = msg || "The object you're accessing is read-only.  Probably because it's internally managed by OGR."
      super(message)
    end
  end

  class UnsupportedFieldType < StandardError
  end

  class UnsupportedGeometryType < StandardError
  end

  class UnsupportedOperation < StandardError
  end

  class UnsupportedSRS < StandardError
  end
end
