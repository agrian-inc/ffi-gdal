# typed: true
# frozen_string_literal: true

module OGR
  class GeometryFieldDefinition
    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      return unless pointer && !pointer.null?

      FFI::OGR::API.OGR_GFld_Destroy(pointer)
    end

    # @return [FFI::Pointer]
    attr_reader :c_pointer

    # @param value [Boolean]
    attr_writer :read_only

    # @param name_or_pointer [String, FFI::Pointer]
    # @param type [FFI::OGR::API::WKBGeometryType]
    def initialize(name_or_pointer, type = :wkbUnknown)
      pointer =
        case name_or_pointer
        when String
          ptr = FFI::OGR::API.OGR_GFld_Create(name_or_pointer, type)
          ptr.autorelease = false

          FFI::AutoPointer.new(ptr, GeometryFieldDefinition.method(:release))
        when FFI::AutoPointer
          name_or_pointer
        when FFI::Pointer
          ptr = name_or_pointer
          ptr.autorelease = false

          FFI::AutoPointer.new(ptr, GeometryFieldDefinition.method(:release))
        else
          log "Dunno what to do with #{name_or_pointer}"
        end

      if !pointer.is_a?(FFI::Pointer) || pointer.null?
        raise OGR::InvalidGeometryFieldDefinition,
              "Unable to create #{self.class.name} from #{name_or_pointer}"
      end

      @c_pointer = pointer
      @read_only = false
    end

    # @return [Boolean]
    def read_only?
      @read_only || false
    end

    def destroy!
      GeometryFieldDefinition.release(@c_pointer)

      @c_pointer = nil
    end

    # @return [String]
    def name
      name, ptr = FFI::OGR::API.OGR_GFld_GetNameRef(@c_pointer)
      ptr.autorelease = false

      name
    end

    # @param new_name [String]
    def name=(new_name)
      raise OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetName(@c_pointer, new_name)
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def type
      FFI::OGR::API.OGR_GFld_GetType(@c_pointer)
    end

    # @param new_type [FFI::OGR::API::WKBGeometryType]
    def type=(new_type)
      raise OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetType(@c_pointer, new_type)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_ptr = FFI::OGR::API.OGR_GFld_GetSpatialRef(@c_pointer)

      if spatial_ref_ptr.nil? || spatial_ref_ptr.null?
        nil
      else
        auto_ptr = FFI::AutoPointer.new(spatial_ref_ptr, OGR::SpatialReference.method(:release))

        OGR::SpatialReference.new(auto_ptr)
      end
    end

    # This function drops the reference of the previously set SRS object and
    # acquires a new reference on the passed object (if non-NULL).
    #
    # @param new_spatial_reference [OGR::SpatialReference, FFI::Pointer]
    def spatial_reference=(new_spatial_reference)
      raise OGR::ReadOnlyObject if @read_only

      spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_reference, autorelease: false)
      raise if spatial_ref_ptr.null?

      FFI::OGR::API.OGR_GFld_SetSpatialRef(
        @c_pointer,
        spatial_ref_ptr
      )
    end

    # @return [Boolean]
    def ignored?
      FFI::OGR::API.OGR_GFld_IsIgnored(@c_pointer)
    end

    # @param value [Boolean]
    def ignore=(value)
      raise OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetIgnored(@c_pointer, value)
    end
  end
end
