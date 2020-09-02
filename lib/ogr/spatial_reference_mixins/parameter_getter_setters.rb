# typed: true
# frozen_string_literal: true

module OGR
  module SpatialReferenceMixins
    module ParameterGetterSetters
      # @param name [String] The case-insensitive tree node to look for.
      # @param child [Integer] The child of the node to fetch.
      # @return [String, nil]
      def attribute_value(name, child = 0)
        FFI::OGR::SRSAPI.OSRGetAttrValue(@c_pointer, name, child)
      end

      # @param path [String] Path to the node to update/set.  If nested, use the
      #   pipe symbol to denote nesting.  i.e. 'GEOCCS|UNIT'.
      # @param value [String] The new value for the node/path.  Should be a String,
      #   but if not, will be converted for you.
      # @raise [OGR::Failure]
      def set_attribute_value(path, value)
        OGR::ErrorHandling.handle_ogr_err("Unable to set attribute (#{path}) to value #{value}") do
          FFI::OGR::SRSAPI.OSRSetAttrValue(@c_pointer, path, value.to_s)
        end
      end

      # @return [Hash{unit_name: String, value: Float}]  +unit_name+ is the name
      #   of the unit type ("degree" or "radian").  +value+ is the number to
      #   multiply angular distances to transform them to radians.
      def angular_units
        name_ptr = GDAL._pointer_pointer(:string)
        value = FFI::OGR::SRSAPI.OSRGetAngularUnits(@c_pointer, name_ptr)

        { unit_name: GDAL._read_pointer_pointer_safely(name_ptr, :string), value: value }
      end

      # @param unit_label [String]
      # @param transform_to_radians [Float] The value to multiply an angle to
      #   transform the value to radians.
      # @raise [OGR::Failure]
      def set_angular_units(unit_label, transform_to_radians)
        msg = "Unable to set angular units to #{unit_label} (transform to radians? #{transform_to_radians})"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRSetAngularUnits(@c_pointer, unit_label, transform_to_radians.to_f)
        end
      end

      # @return [Hash{unit_name: String, value: Float}]  +unit_name+ is the name
      #   of the unit type (e.g. "Meters"). +value+ is the number to multiply
      #   linear distances to transform them to meters.
      def linear_units
        name_ptr = GDAL._pointer_pointer(:string)
        value = FFI::OGR::SRSAPI.OSRGetLinearUnits(@c_pointer, name_ptr)

        { unit_name: GDAL._read_pointer_pointer_safely(name_ptr, :string), value: value }
      end

      # @param unit_label [String]
      # @param transform_to_meters [Float] The value to multiply a length to
      #   transform the value to meters.
      # @raise [OGR::Failure]
      def set_linear_units(unit_label, transform_to_meters)
        msg = "Unable to set linear units to #{unit_label} (transform to meters? #{transform_to_meters})"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRSetLinearUnits(@c_pointer, unit_label, transform_to_meters.to_f)
        end
      end

      # Does the same as #set_linear_units, but also converts parameters to use
      # the new units.
      #
      # @param unit_label [String]
      # @param transform_to_meters [Float] The value to multiply a length to
      #   transform the value to meters.
      # @raise [OGR::Failure]
      def set_linear_units_and_update_parameters(unit_label, transform_to_meters)
        msg = "Unable to set linear units to #{unit_label} (transform to meters? #{transform_to_meters}) and update" \
          'parameters'

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRSetLinearUnitsAndUpdateParameters(@c_pointer, unit_label, transform_to_meters.to_f)
        end
      end

      # The linear units for the projection.
      #
      # @param target_key [String] I.e. "PROJCS" or "VERT_CS".
      # @return [Hash]
      def target_linear_units(target_key)
        name_ptr = GDAL._pointer_pointer(:string)
        value = FFI::OGR::SRSAPI.OSRGetTargetLinearUnits(@c_pointer, target_key, name_ptr)

        { unit_name: GDAL._read_pointer_pointer_safely(name_ptr, :string), value: value }
      end

      # @param target_key [String] The keyword to set linear units for ("PROJCS",
      #   "VERT_CS", etc.).
      # @param unit_label [String] Name of the units to be used.
      # @param transform_to_meters [Float] The value to multiple a length to
      #   transform the value to meters.
      # @raise [OGR::Failure]
      def set_target_linear_units(target_key, unit_label, transform_to_meters)
        msg = "Unable to set target (#{target_key}) linear units to #{unit_label} " \
          "(transform to meters? #{transform_to_meters})"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRSetTargetLinearUnits(@c_pointer, target_key, unit_label, transform_to_meters)
        end
      end

      # @return [Hash]
      def prime_meridian
        pm_ptr = GDAL._pointer_pointer(:string)
        value = FFI::OGR::SRSAPI.OSRGetPrimeMeridian(@c_pointer, pm_ptr)

        { name: GDAL._read_pointer_pointer_safely(pm_ptr, :string), value: value }
      end
    end
  end
end
