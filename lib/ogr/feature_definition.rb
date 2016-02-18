require_relative '../ogr'
require_relative 'feature_definition_extensions'

module OGR
  class FeatureDefinition
    include FeatureDefinitionExtensions

    # @return [FFI::Pointer] C pointer of the C FeatureDefn.
    attr_reader :c_pointer

    # @param name_or_pointer [String, FFI::Pointer] When given a String, it will
    #   create a new FeatureDefinition with that name. When given an
    #   FFI::Pointer, the new object will simply wrap the C FeatureDefinition
    #   at that address.
    def initialize(name_or_pointer)
      @c_pointer = if name_or_pointer.is_a? String
                     FFI::OGR::API.OGR_FD_Create(name_or_pointer)
                   else
                     name_or_pointer
                   end

      if !@c_pointer.is_a?(FFI::Pointer) || @c_pointer.null?
        fail OGR::InvalidFeatureDefinition, "Unable to create #{self.class.name} from #{name_or_pointer}"
      end

      close_me = -> { FFI::OGR::API.OGR_FD_Destroy(@c_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def release!
      FFI::OGR::API.OGR_FD_Release(@c_pointer)
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_FD_GetName(@c_pointer)
    end

    # @return [Fixnum]
    def field_count
      FFI::OGR::API.OGR_FD_GetFieldCount(@c_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::FieldDefinition] This does not need to be destroyed
    def field_definition(index)
      field_definition_ptr =
        FFI::OGR::API.OGR_FD_GetFieldDefn(@c_pointer, index)
      return nil if field_definition_ptr.null?

      OGR::FieldDefinition.new(field_definition_ptr, nil)
    end

    # @param field_definition [OGR::FieldDefinition, FFI::Pointer]
    def add_field_definition(field_definition)
      field_definition_ptr = GDAL._pointer(OGR::FieldDefinition, field_definition)

      if field_definition_ptr.nil?
        fail OGR::InvalidFieldDefinition, "Unable to add OGR::FieldDefinition: '#{field_definition}'"
      end

      FFI::OGR::API.OGR_FD_AddFieldDefn(@c_pointer, field_definition_ptr)
    end

    # @param index [Fixnum] Index of the field definition to delete.
    # @return [Boolean]
    def delete_field_definition(index)
      ogr_err = FFI::OGR::API.OGR_FD_DeleteFieldDefn(
        @c_pointer,
        index)

      ogr_err.handle_result "Unable to delete field definition at index #{index}"
    end

    # @param name [String]
    # @return [Fixnum] nil if no match found
    def field_index(name)
      result = FFI::OGR::API.OGR_FD_GetFieldIndex(@c_pointer, name)

      result < 0 ? nil : result
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def geometry_type
      FFI::OGR::API.OGR_FD_GetGeomType(@c_pointer)
    end

    # @param new_type [FFI::OGR::API::WKBGeometryType]
    def geometry_type=(new_type)
      FFI::OGR::API.OGR_FD_SetGeomType(@c_pointer, new_type)
    end

    # @return [Boolean]
    def geometry_ignored?
      FFI::OGR::API.OGR_FD_IsGeometryIgnored(@c_pointer)
    end

    # @param ignore [Boolean]
    def ignore_geometry!(ignore = true)
      FFI::OGR::API.OGR_FD_SetGeometryIgnored(@c_pointer, ignore)
    end

    # @return [Boolean]
    def style_ignored?
      FFI::OGR::API.OGR_FD_IsStyleIgnored(@c_pointer)
    end

    # @param ignore [Boolean]
    def ignore_style!(ignore = true)
      FFI::OGR::API.OGR_FD_SetStyleIgnored(@c_pointer, ignore)
    end

    # @return [Fixnum]
    def geometry_field_count
      FFI::OGR::API.OGR_FD_GetGeomFieldCount(@c_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::GeometryFieldDefinition]
    def geometry_field_definition(index)
      geometry_field_definition_ptr =
        FFI::OGR::API.OGR_FD_GetGeomFieldDefn(@c_pointer, index)
      return nil if geometry_field_definition_ptr.null?

      OGR::GeometryFieldDefinition.new(geometry_field_definition_ptr)
    end

    # @param name [String]
    # @return [Fixnum]
    def geometry_field_index(name)
      result = FFI::OGR::API.OGR_FD_GetGeomFieldIndex(@c_pointer, name)

      result < 0 ? nil : result
    end

    # @param geometry_field_definition [OGR::GeometryFieldDefinition, FFI::Pointer]
    def add_geometry_field_definition(geometry_field_definition)
      geometry_field_definition_ptr = GDAL._pointer(OGR::GeometryFieldDefinition,
        geometry_field_definition)
      FFI::OGR::API.OGR_FD_AddGeomFieldDefn(@c_pointer,
        geometry_field_definition_ptr)
    end

    # @param index [Fixnum]
    # @return [Boolean]
    def delete_geometry_field_definition(index)
      ogr_err = FFI::OGR::API.OGR_FD_DeleteGeomFieldDefn(@c_pointer,
        index)

      ogr_err.handle_result "Unable to delete geometry field definition at index #{index}"
    end

    # @param other_feature_definition [OGR::Feature, FFI::Pointer]
    # @return [Boolean]
    def same?(other_feature_definition)
      fd_ptr = GDAL._pointer(OGR::FeatureDefinition, other_feature_definition)

      FFI::OGR::API.OGR_FD_IsSame(@c_pointer, fd_ptr)
    end
  end
end
