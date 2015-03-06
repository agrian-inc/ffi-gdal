require_relative '../ffi/ogr'
require_relative 'feature_extensions'
require_relative 'feature_definition'
require_relative 'field_definition'
require 'date'

module OGR
  class Feature
    include FeatureExtensions

    # @param fd_or_pointer [OGR::FeatureDefinition, FFI::Pointer] Must either be
    #   a FeatureDefinition (i.e. normal Feature creation) or a Pointer (in the
    #   case a handle to a C OGR Feature needs to be wrapped with this object).
    def initialize(fd_or_pointer)
      @feature_pointer = if fd_or_pointer.is_a? OGR::FeatureDefinition
                           FFI::OGR::API.OGR_F_Create(fd_or_pointer.c_pointer)
                         else
                           fd_or_pointer
                         end

      if !@feature_pointer.is_a?(FFI::Pointer) || @feature_pointer.null?
        fail OGR::InvalidFeature, "Unable to create Feature with #{fd_or_pointer}"
      end

      close_me = -> { FFI::OGR::API.OGR_F_Destroy(@feature_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @feature_pointer
    end

    # @return [OGR::Feature]
    # @raise [OGR::Failure] If, for some reason, the clone fails.
    def clone
      feature_ptr = FFI::OGR::API.OGR_F_Clone(@feature_pointer)
      fail OGR::Failure, 'Unable to clone feature' if feature_ptr.nil?

      OGR::Feature.new(feature_ptr)
    end

    # Dumps the feature out to the file in human-readable form.
    #
    # @param file_name [String]
    def dump_readable(file_name)
      FFI::OGR::API.OGR_F_DumpReadable(@feature_pointer, file_name)
    end

    # Overwrites the contents of this feature from the geometry and attributes
    # of the +other_feature+.
    #
    # @param other_feature [OGR::Feature]
    # @param be_forgiving [Boolean] +true+ if the operation should continue
    #   despite lacking output fields matching some of the source fields.
    # @param with_map [Array<Fixnum>]
    # TODO: Implement +with_map+
    def set_from!(other_feature, be_forgiving = false, with_map: nil)
      fail NotImplementedError, 'with_map: is not yet supported' if with_map

      ogr_err = FFI::OGR::API.OGR_F_SetFrom(@feature_pointer, other_feature_ptr)

      ogr_err.handle_result
    end

    # This will always be the same as the field count for the feature
    # definition.
    #
    # @return [Fixnum]
    def field_count
      FFI::OGR::API.OGR_F_GetFieldCount(@feature_pointer)
    end

    # @param index [Fixnum]
    # @param value [String]
    def set_field_string(index, value)
      FFI::OGR::API.OGR_F_SetFieldString(@feature_pointer, index, value)
    end

    # @param index [Fixnum]
    # @param value [Fixnum]
    def set_field_integer(index, value)
      FFI::OGR::API.OGR_F_SetFieldInteger(@feature_pointer, index, value)
    end

    # @param index [Fixnum]
    # @param value [Float]
    def set_field_double(index, value)
      FFI::OGR::API.OGR_F_SetFieldDouble(@feature_pointer, index, value)
    end

    # @param index [Fixnum]
    # @param values [Array<String>]
    # @raise [GDAL::Error] If index isn't valid
    def set_field_string_list(index, values)
      values_ptr = GDAL._string_array_to_pointer(values)

      FFI::OGR::API.OGR_F_SetFieldStringList(
        @feature_pointer,
        index,
        values_ptr)
    end

    # @param index [Fixnum]
    # @param values [Array<Fixnum>]
    def set_field_integer_list(index, values)
      values_ptr = FFI::MemoryPointer.new(:int, values.size)
      values_ptr.write_array_of_int(values)

      FFI::OGR::API.OGR_F_SetFieldIntegerList(
        @feature_pointer,
        index,
        values.size,
        values_ptr)
    end

    # @param index [Fixnum]
    # @param values [Array<Float>]
    def set_field_double_list(index, values)
      values_ptr = FFI::MemoryPointer.new(:double, values.size)
      values_ptr.write_array_of_double(values)

      FFI::OGR::API.OGR_F_SetFieldDoubleList(
        @feature_pointer,
        index,
        values.size,
        values_ptr)
    end

    # @param index [Fixnum]
    # @param value [FFI::OGR::Field]
    def set_field_raw(index, value)
      raw_field_ptr = FFI::MemoryPointer.new(value)
      usable_raw_field = FFI::OGR::Field.new(raw_field_ptr)

      unless valid_raw_field?(index, usable_raw_field)
        fail TypeError,
          "Raw field is not of required field type: #{field_definition(index).type}"
      end

      FFI::OGR::API.OGR_F_SetFieldRaw(@feature_pointer, index, value)
    end

    # @param index [Fixnum]
    # @param value [String]
    def set_field_binary(index, value)
      fail TypeError, 'value must be a binary string' unless value.is_a? String

      value_ptr = FFI::MemoryPointer.new(:uchar, value.length)
      value_ptr.put_bytes(0, value)

      FFI::OGR::API.OGR_F_SetFieldBinary(
        @feature_pointer,
        index,
        value.length,
        value_ptr)
    end

    # @param index [Fixnum]
    # @param [Date, Time, DateTime]
    def set_field_date_time(index, value)
      time = value.to_time
      zone = OGR._format_time_zone_for_ogr(time.zone)

      FFI::OGR::API.OGR_F_SetFieldDateTime(@feature_pointer, index,
        time.year,
        time.month,
        time.day,
        time.hour,
        time.min,
        time.sec,
        zone)
    end

    # @param index [Fixnum]
    # @return [OGR::FieldDefinition]
    def field_definition(index)
      field_pointer = FFI::OGR::API.OGR_F_GetFieldDefnRef(@feature_pointer, index)
      return nil if field_pointer.null?

      OGR::FieldDefinition.new(field_pointer, nil)
    end

    # @param name [String]
    # @return [Fixnum, nil]
    def field_index(name)
      result = FFI::OGR::API.OGR_F_GetFieldIndex(@feature_pointer, name)

      result < 0 ? nil : result
    end

    # @param index [Fixnum]
    # @return [Boolean]
    def field_set?(index)
      FFI::OGR::API.OGR_F_IsFieldSet(@feature_pointer, index)
    end

    # @param index [Fixnum]
    def unset_field(index)
      FFI::OGR::API.OGR_F_UnsetField(@feature_pointer, index)
    end

    # @return [OGR::FeatureDefinition,nil]
    def definition
      feature_defn_ptr = FFI::OGR::API.OGR_F_GetDefnRef(@feature_pointer)
      return nil if feature_defn_ptr.null?

      OGR::FeatureDefinition.new(feature_defn_ptr)
    end

    # @return [OGR::Geometry]
    def geometry
      geometry_ptr = FFI::OGR::API.OGR_F_GetGeometryRef(@feature_pointer)
      return nil if geometry_ptr.null?

      OGR::Geometry.factory(geometry_ptr)
    end

    # @param new_geometry [OGR::Geometry]
    # @return +true+ if successful, otherwise raises an OGR exception.
    def geometry=(new_geometry)
      ogr_err = FFI::OGR::API.OGR_F_SetGeometryDirectly(@feature_pointer, new_geometry.c_pointer)

      ogr_err.handle_result
    end

    # @return [OGR::Geometry]
    def steal_geometry
      geometry_ptr = FFI::OGR::API.OGR_F_StealGeometry(@feature_pointer)
      fail OGR::Failure, "Unable to steal geometry." if geometry_ptr.nil?

      OGR::Geometry.factory(geometry_ptr)
    end

    # @return [Fixnum]
    def fid
      FFI::OGR::API.OGR_F_GetFID(@feature_pointer)
    end

    # @param new_fid [Fixnum]
    # @return +true+ if successful, otherwise raises an OGR exception.
    def fid=(new_fid)
      ogr_err = FFI::OGR::API.OGR_F_SetFID(@feature_pointer, new_fid)

      ogr_err.handle_result
    end

    # The number of Geometries in this feature.
    #
    # @return [Fixnum]
    def geometry_field_count
      FFI::OGR::API.OGR_F_GetGeomFieldCount(@feature_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::GeometryFieldDefinition] A read-only
    #   OGR::GeometryFieldDefinition.
    # @raise [OGR::InvalidGeometryFieldDefinition] If there isn't one at
    #   +index+.
    def geometry_field_definition(index)
      gfd_ptr = FFI::OGR::API.OGR_F_GetGeomFieldDefnRef(@feature_pointer, index)
      return nil if gfd_ptr.nil?

      gfd = OGR::GeometryFieldDefinition.new(gfd_ptr)
      gfd.read_only = true

      gfd
    end

    # @param name [String]
    # @return index [Fixnum]
    def geometry_field_index(name)
      FFI::OGR::API.OGR_F_GetGeomFieldIndex(@feature_pointer, name)
    end

    # @param index [Fixnum]
    # @return [OGR::Geometry, nil] A read-only OGR::Geometry.
    def geometry_field(index)
      geometry_ptr = FFI::OGR::API.OGR_F_GetGeomFieldRef(@feature_pointer, index)
      return nil if geometry_ptr.nil? || geometry_ptr.null?

      geometry = OGR::Geometry.factory(geometry_ptr)
      geometry.read_only = true

      geometry
    end

    # @param index [Fixnum]
    # @param [OGR::Geometry]
    def set_geometry_field(index, geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      fail OGR::InvalidGeometry if geometry_ptr.nil?

      ogr_err =
        # FFI::OGR::API.OGR_F_SetGeomFieldDirectly(@feature_pointer, index, geometry_ptr)
        FFI::OGR::API.OGR_F_SetGeomField(@feature_pointer, index, geometry_ptr)

      ogr_err.handle_result
    end

    # @return [Boolean]
    def equal?(other_feature)
      FFI::OGR::API.OGR_F_Equal(@feature_pointer, feature_pointer_from(other_feature))
    end
    alias_method :equals?, :equal?

    # @param index [Fixnum]
    # @return [Fixnum]
    def field_as_integer(index)
      FFI::OGR::API.OGR_F_GetFieldAsInteger(@feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<Fixnum>]
    def field_as_integer_list(index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      list_ptr =
        FFI::OGR::API.OGR_F_GetFieldAsIntegerList(@feature_pointer, index, list_size_ptr)
      return [] if list_ptr.null?

      list_ptr.read_array_of_int(list_size_ptr.read_int)
    end

    # @param index [Fixnum]
    # @return [Float]
    def field_as_double(index)
      FFI::OGR::API.OGR_F_GetFieldAsDouble(@feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<Float>]
    def field_as_double_list(index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      list_ptr =
        FFI::OGR::API.OGR_F_GetFieldAsDoubleList(@feature_pointer, index, list_size_ptr)
      return [] if list_ptr.null?

      list_ptr.read_array_of_double(list_size_ptr.read_int)
    end

    # @param index [Fixnum]
    # @return [String]
    def field_as_string(index)
      FFI::OGR::API.OGR_F_GetFieldAsString(@feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<String>]
    def field_as_string_list(index)
      list_ptr =
        FFI::OGR::API.OGR_F_GetFieldAsStringList(@feature_pointer, index)
      return [] if list_ptr.null?

      list_ptr.get_array_of_string(0)
    end

    # @param index [Fixnum]
    # @return [String]
    def field_as_binary(index)
      byte_count_ptr = FFI::MemoryPointer.new(:int)
      binary_data = FFI::OGR::API.OGR_F_GetFieldAsBinary(
        @feature_pointer,
        index,
        byte_count_ptr
      )

      byte_count = byte_count_ptr.read_int
      string = byte_count > 0 ? binary_data.read_bytes(byte_count) : ''

      string.unpack('C*')
    end

    def field_as_date_time(index)
      year_ptr = FFI::MemoryPointer.new(:int)
      month_ptr = FFI::MemoryPointer.new(:int)
      day_ptr = FFI::MemoryPointer.new(:int)
      hour_ptr = FFI::MemoryPointer.new(:int)
      minute_ptr = FFI::MemoryPointer.new(:int)
      second_ptr = FFI::MemoryPointer.new(:int)
      time_zone_flag_ptr = FFI::MemoryPointer.new(:int)

      result = FFI::OGR::API.OGR_F_GetFieldAsDateTime(
        @feature_pointer,
        index,
        year_ptr,
        month_ptr,
        day_ptr,
        hour_ptr,
        minute_ptr,
        second_ptr,
        time_zone_flag_ptr
      )
      return nil unless result

      formatted_tz = OGR._format_time_zone_for_ruby(time_zone_flag_ptr.read_int)

      if formatted_tz
        DateTime.new(
          year_ptr.read_int,
          month_ptr.read_int,
          day_ptr.read_int,
          hour_ptr.read_int,
          minute_ptr.read_int,
          second_ptr.read_int,
          formatted_tz
          )
      else
        DateTime.new(
          year_ptr.read_int,
          month_ptr.read_int,
          day_ptr.read_int,
          hour_ptr.read_int,
          minute_ptr.read_int,
          second_ptr.read_int
          )
      end
    end

    # @return [String]
    def style_string
      FFI::OGR::API.OGR_F_GetStyleString(@feature_pointer)
    end

    # @param new_style [String]
    def style_string=(new_style)
      FFI::OGR::API.OGR_F_SetStyleString(@feature_pointer, new_style)
    end

    # @return [OGR::StyleTable]
    def style_table
      style_table_ptr = FFI::OGR::API.OGR_F_GetStyleTable(@feature_pointer)
      return nil if style_table_ptr.nil? || style_table_ptr.null?

      OGR::StyleTable.new(style_table_ptr)
    end

    # @param new_style_table [OGR::StyleTable]
    def style_table=(new_style_table)
      new_style_table_ptr = GDAL._pointer(OGR::StyleTable, new_style_table)
      fail OGR::InvalidStyleTable unless new_style_table_ptr

      FFI::OGR::API.OGR_F_SetStyleTableDirectly(@field_pointer, new_style_table_ptr)
    end

    private

    def feature_pointer_from(feature)
      if feature.is_a? OGR::Feature
        feature.c_pointer
      elsif feature.is_a? FFI::Pointer
        feature
      end
    end
  end
end
