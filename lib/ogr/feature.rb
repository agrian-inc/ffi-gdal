# typed: false
# frozen_string_literal: true

require 'date'
require_relative '../ogr'
require_relative '../gdal'

module OGR
  class Feature
    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      return unless pointer && !pointer.null?

      FFI::OGR::API.OGR_F_Destroy(pointer)
    end

    # @return [FFI::Pointer] C pointer of the C Feature.
    attr_reader :c_pointer

    # @param fd_or_pointer [OGR::FeatureDefinition, FFI::Pointer] Must either be
    #   a FeatureDefinition (i.e. normal Feature creation) or a Pointer (in the
    #   case a handle to a C OGR Feature needs to be wrapped with this object).
    def initialize(fd_or_pointer)
      pointer = case fd_or_pointer
                when OGR::FeatureDefinition then FFI::OGR::API.OGR_F_Create(fd_or_pointer.c_pointer)
                when FFI::Pointer
                  fd_or_pointer.autorelease = false
                  fd_or_pointer
                else
                  raise OGR::InvalidFeature, 'OGR::Feature must be instantiated with valid feature'
                end

      if !pointer.is_a?(FFI::Pointer) || pointer.null?
        raise OGR::InvalidFeature, "Unable to create Feature with #{fd_or_pointer}"
      end

      # pointer.autorelease = false

      # @c_pointer = FFI::AutoPointer.new(pointer, Feature.method(:release))
      @c_pointer = pointer
    end

    def destroy!
      Feature.release(@c_pointer)

      @c_pointer = nil
    end

    # @return [OGR::Feature]
    # @raise [OGR::Failure] If, for some reason, the clone fails.
    def clone
      # This new feature is owned by the caller and must be released accordingly.
      feature_ptr = FFI::OGR::API.OGR_F_Clone(@c_pointer)
      raise OGR::Failure, 'Unable to clone feature' if feature_ptr.nil?

      OGR::Feature.new(feature_ptr)
    end

    # Dumps the feature out to the file in human-readable form.
    #
    # @param file_path [String]
    def dump_readable(file_path = nil)
      file_ptr = file_path ? FFI::CPL::Conv.CPLOpenShared(file_path, 'w', false) : nil
      FFI::OGR::API.OGR_F_DumpReadable(@c_pointer, file_ptr)
      FFI::CPL::Conv.CPLCloseShared(file_ptr) if file_ptr
    end

    # Overwrites the contents of this feature from the geometry and attributes
    # of the +other_feature+.
    #
    # @param _other_feature [OGR::Feature]
    # @param _be_forgiving [Boolean] +true+ if the operation should continue
    #   despite lacking output fields matching some of the source fields.
    # @param with_map [Array<Integer>]
    # @raise [OGR::Failure]
    # TODO: Implement +with_map+
    def set_from!(_other_feature, _be_forgiving: false, with_map: nil)
      raise NotImplementedError, 'with_map: is not yet supported' if with_map

      OGR::ErrorHandling.handle_ogr_err('Unable to set from other feature') do
        FFI::OGR::API.OGR_F_SetFrom(@c_pointer, other_feature_ptr)
      end
    end

    # This will always be the same as the field count for the feature
    # definition.
    #
    # @return [Integer]
    def field_count
      FFI::OGR::API.OGR_F_GetFieldCount(@c_pointer)
    end

    # @param index [Integer]
    # @param value [String]
    def set_field_string(index, value)
      FFI::OGR::API.OGR_F_SetFieldString(@c_pointer, index, value)
    end

    # @param index [Integer]
    # @param value [Integer]
    def set_field_integer(index, value)
      FFI::OGR::API.OGR_F_SetFieldInteger(@c_pointer, index, value)
    end

    # @param index [Integer]
    # @param value [Float]
    def set_field_double(index, value)
      FFI::OGR::API.OGR_F_SetFieldDouble(@c_pointer, index, value)
    end

    # @param index [Integer]
    # @param values [Array<String>]
    # @raise [GDAL::Error] If index isn't valid
    def set_field_string_list(index, values)
      values_ptr = GDAL._string_array_to_pointer(values)

      FFI::OGR::API.OGR_F_SetFieldStringList(
        @c_pointer,
        index,
        values_ptr
      )
    end

    # @param index [Integer]
    # @param values [Array<Integer>]
    def set_field_integer_list(index, values)
      values_ptr = FFI::MemoryPointer.new(:int, values.size)
      values_ptr.write_array_of_int(values)

      FFI::OGR::API.OGR_F_SetFieldIntegerList(
        @c_pointer,
        index,
        values.size,
        values_ptr
      )
    end

    # @param index [Integer]
    # @param values [Array<Float>]
    def set_field_double_list(index, values)
      values_ptr = FFI::MemoryPointer.new(:double, values.size)
      values_ptr.write_array_of_double(values)

      FFI::OGR::API.OGR_F_SetFieldDoubleList(
        @c_pointer,
        index,
        values.size,
        values_ptr
      )
    end

    # @param index [Integer]
    # @param field [OGR::Field]
    def set_field_raw(index, field)
      usable_raw_field = field.c_struct

      FFI::OGR::API.OGR_F_SetFieldRaw(@c_pointer, index, usable_raw_field)
    end

    # @param index [Integer]
    # @param value [String]
    def set_field_binary(index, value)
      raise TypeError, 'value must be a binary string' unless value.is_a? String

      value_ptr = FFI::MemoryPointer.new(:uchar, value.length)
      value_ptr.put_bytes(0, value)

      FFI::OGR::API.OGR_F_SetFieldBinary(
        @c_pointer,
        index,
        value.length,
        value_ptr
      )
    end

    # @param index [Integer]
    # @param value [Date, Time, DateTime]
    def set_field_date_time(index, value)
      time = value.to_time
      zone = OGR._format_time_zone_for_ogr(value.zone)

      FFI::OGR::API.OGR_F_SetFieldDateTime(@c_pointer, index,
                                           time.year,
                                           time.month,
                                           time.day,
                                           time.hour,
                                           time.min,
                                           time.sec,
                                           zone)
    end

    # NOTE: Do not modify the FieldDefinition that's returned here.
    #
    # @param index [Integer]
    # @return [OGR::FieldDefinition]
    def field_definition(index)
      # This returns an internal reference and should not be deleted or modified
      field_pointer = FFI::OGR::API.OGR_F_GetFieldDefnRef(@c_pointer, index)
      field_pointer.autorelease = false

      return nil if field_pointer.null?

      OGR::FieldDefinition.new(field_pointer, nil)
    end

    # @param name [String]
    # @return [Integer, nil]
    def field_index(name)
      result = FFI::OGR::API.OGR_F_GetFieldIndex(@c_pointer, name)

      result.negative? ? nil : result
    end

    # @param index [Integer]
    # @return [Boolean]
    def field_set?(index)
      FFI::OGR::API.OGR_F_IsFieldSet(@c_pointer, index)
    end

    # @param index [Integer]
    def unset_field(index)
      FFI::OGR::API.OGR_F_UnsetField(@c_pointer, index)
    end

    # @return [OGR::FeatureDefinition,nil]
    def definition
      feature_defn_ptr = FFI::OGR::API.OGR_F_GetDefnRef(@c_pointer)
      feature_defn_ptr.autorelease = false

      return nil if feature_defn_ptr.null?

      OGR::FeatureDefinition.new(feature_defn_ptr)
    end

    # NOTE: Do not modify the Geometry that's returned here.
    #
    # @return [OGR::Geometry]
    def geometry
      # This returns an internal reference and should not be deleted or modified
      geometry_ptr = FFI::OGR::API.OGR_F_GetGeometryRef(@c_pointer)
      geometry_ptr.autorelease = false

      return nil if geometry_ptr.null?

      OGR::Geometry.factory(geometry_ptr)
    end

    # Sets the geometry of the feature by making a copy of +new_geometry+.
    #
    # @param new_geometry [OGR::Geometry]
    # @raise [OGR::Failure]
    def set_geometry(new_geometry) # rubocop:disable Naming/AccessorMethodName
      OGR::ErrorHandling.handle_ogr_err('Unable to set geometry on feature') do
        FFI::OGR::API.OGR_F_SetGeometry(@c_pointer, new_geometry.c_pointer)
      end
    end

    # Sets the geometry of the feature by taking ownership of +new_geometry.
    #
    # @param new_geometry [OGR::Geometry]
    # @raise [OGR::Failure]
    def set_geometry_directly(new_geometry) # rubocop:disable Naming/AccessorMethodName
      new_geometry.c_pointer.autorelease = false

      OGR::ErrorHandling.handle_ogr_err('Unable to set geometry directly on feature') do
        FFI::OGR::API.OGR_F_SetGeometryDirectly(@c_pointer, new_geometry.c_pointer)
      end
    end
    alias geometry= set_geometry_directly

    # Takes away ownership of the Feature's Geometry and returns it to the caller.
    #
    # @return [OGR::Geometry]
    def steal_geometry
      geometry_ptr = FFI::OGR::API.OGR_F_StealGeometry(@c_pointer)
      raise OGR::Failure, 'Unable to steal geometry.' if geometry_ptr.nil? || geometry_ptr.null?

      OGR::Geometry.factory(geometry_ptr)
    end

    # @return [Integer]
    def fid
      FFI::OGR::API.OGR_F_GetFID(@c_pointer)
    end

    # @param new_fid [Integer]
    # @raise [OGR::Failure]
    def fid=(new_fid)
      OGR::ErrorHandling.handle_ogr_err('Unable to set FID') do
        FFI::OGR::API.OGR_F_SetFID(@c_pointer, new_fid)
      end
    end

    # The number of Geometries in this feature.
    #
    # @return [Integer]
    def geometry_field_count
      FFI::OGR::API.OGR_F_GetGeomFieldCount(@c_pointer)
    end

    # NOTE: Do not modify the GeometryFieldDefinition that's returned here.
    #
    # @param index [Integer]
    # @return [OGR::GeometryFieldDefinition] A read-only
    #   OGR::GeometryFieldDefinition.
    # @raise [OGR::InvalidGeometryFieldDefinition] If there isn't one at
    #   +index+.
    def geometry_field_definition(index)
      # This returns an internal reference and should not be deleted or modified
      gfd_ptr = FFI::OGR::API.OGR_F_GetGeomFieldDefnRef(@c_pointer, index)
      gfd_ptr.autorelease = false

      return nil if gfd_ptr.nil?

      gfd = OGR::GeometryFieldDefinition.new(gfd_ptr)
      gfd.read_only = true

      gfd
    end

    # @param name [String]
    # @return [Integer]
    def geometry_field_index(name)
      FFI::OGR::API.OGR_F_GetGeomFieldIndex(@c_pointer, name)
    end

    # NOTE: Do not modify the Geometry that's returned here.
    #
    # @param index [Integer]
    # @return [OGR::Geometry, nil] A read-only OGR::Geometry.
    def geometry_field(index)
      # This returns an internal reference and should not be deleted or modified
      geometry_ptr = FFI::OGR::API.OGR_F_GetGeomFieldRef(@c_pointer, index)
      geometry_ptr.autorelease = false

      return nil if geometry_ptr.nil? || geometry_ptr.null?

      OGR::Geometry.factory(geometry_ptr)
    end

    # Sets the feature geometry of a specified geometry field by making a copy
    # of +geometry+.
    #
    # @param index [Integer]
    # @param geometry [OGR::Geometry]
    # @raise [OGR::Failure]
    def set_geometry_field(index, geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      raise OGR::InvalidGeometry if geometry_ptr.nil?

      OGR::ErrorHandling.handle_ogr_err("Unable to set geometry field at index #{index}") do
        FFI::OGR::API.OGR_F_SetGeomField(@c_pointer, index, geometry_ptr)
      end
    end

    # Sets the feature geometry of a specified geometry field by taking ownership
    # of +geometry+.
    #
    # @param index [Integer]
    # @param geometry [OGR::Geometry]
    # @raise [OGR::Failure]
    def set_geometry_field_directly(index, geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry, autorelease: false)

      raise OGR::InvalidGeometry if geometry_ptr.nil?

      OGR::ErrorHandling.handle_ogr_err("Unable to set geometry field directly at index #{index}") do
        FFI::OGR::API.OGR_F_SetGeomFieldDirectly(@c_pointer, index, geometry_ptr)
      end
    end

    # @return [Boolean]
    def equal?(other)
      FFI::OGR::API.OGR_F_Equal(@c_pointer, c_pointer_from(other))
    end
    alias equals? equal?

    # @param index [Integer]
    # @return [Integer]
    def field_as_integer(index)
      FFI::OGR::API.OGR_F_GetFieldAsInteger(@c_pointer, index)
    end

    # @param index [Integer]
    # @return [Array<Integer>]
    def field_as_integer_list(index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      #  This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      list_ptr = FFI::OGR::API.OGR_F_GetFieldAsIntegerList(@c_pointer, index, list_size_ptr)
      list_ptr.autorelease = false

      return [] if list_ptr.null?

      list_ptr.read_array_of_int(list_size_ptr.read_int)
    end

    # @param index [Integer]
    # @return [Float]
    def field_as_double(index)
      FFI::OGR::API.OGR_F_GetFieldAsDouble(@c_pointer, index)
    end

    # @param index [Integer]
    # @return [Array<Float>]
    def field_as_double_list(index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      # This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      list_ptr = FFI::OGR::API.OGR_F_GetFieldAsDoubleList(@c_pointer, index, list_size_ptr)
      list_ptr.autorelease = false

      return [] if list_ptr.null?

      list_ptr.read_array_of_double(list_size_ptr.read_int)
    end

    # @param index [Integer]
    # @return [String]
    def field_as_string(index)
      field, ptr = FFI::OGR::API.OGR_F_GetFieldAsString(@c_pointer, index)
      ptr.autorelease = false

      field.force_encoding(Encoding::UTF_8)
    end

    # @param index [Integer]
    # @return [Array<String>]
    def field_as_string_list(index)
      # This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      list_ptr = FFI::OGR::API.OGR_F_GetFieldAsStringList(@c_pointer, index)
      list_ptr.autorelease = false

      return [] if list_ptr.null?

      list_ptr.get_array_of_string(0)
    end

    # @param index [Integer]
    # @return [String]
    def field_as_binary(index)
      byte_count_ptr = FFI::MemoryPointer.new(:int)

      # This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      binary_data_ptr = FFI::OGR::API.OGR_F_GetFieldAsBinary(@c_pointer, index, byte_count_ptr)
      binary_data_ptr.autorelease = false

      byte_count = byte_count_ptr.read_int
      string = byte_count.positive? ? binary_data_ptr.read_bytes(byte_count) : ''

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

      success = FFI::OGR::API.OGR_F_GetFieldAsDateTime(
        @c_pointer,
        index,
        year_ptr,
        month_ptr,
        day_ptr,
        hour_ptr,
        minute_ptr,
        second_ptr,
        time_zone_flag_ptr
      )
      return nil unless success

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
      style, ptr = FFI::OGR::API.OGR_F_GetStyleString(@c_pointer)
      ptr.autorelease = false

      style
    end

    # @param new_style [String]
    def style_string=(new_style)
      FFI::OGR::API.OGR_F_SetStyleString(@c_pointer, new_style)
    end

    # @return [OGR::StyleTable]
    def style_table
      style_table_ptr = FFI::OGR::API.OGR_F_GetStyleTable(@c_pointer)
      style_table_ptr.autorelease = false

      return nil if style_table_ptr.nil? || style_table_ptr.null?

      OGR::StyleTable.new(style_table_ptr)
    end

    # @param new_style_table [OGR::StyleTable]
    def style_table=(new_style_table)
      new_style_table_ptr = GDAL._pointer(OGR::StyleTable, new_style_table, autorelease: false)

      raise OGR::InvalidStyleTable unless new_style_table_ptr

      FFI::OGR::API.OGR_F_SetStyleTableDirectly(@c_pointer, new_style_table_ptr)
    end

    private

    def c_pointer_from(feature)
      case feature
      when OGR::Feature
        feature.c_pointer
      when FFI::Pointer
        feature
      end
    end
  end
end
