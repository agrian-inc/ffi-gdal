# typed: true
# frozen_string_literal: true

require_relative '../ogr'
require_relative '../gdal'
require_relative 'layer_mixins/capability_methods'
require_relative 'layer_mixins/ogr_feature_methods'
require_relative 'layer_mixins/ogr_field_methods'
require_relative 'layer_mixins/ogr_layer_method_methods'
require_relative 'layer_mixins/ogr_query_filter_methods'
require_relative 'layer_mixins/ogr_sql_methods'

module OGR
  class Layer
    include GDAL::MajorObject
    include GDAL::Logger
    include LayerMixins::CapabilityMethods
    include LayerMixins::OGRFeatureMethods
    include LayerMixins::OGRFieldMethods
    include LayerMixins::OGRLayerMethodMethods
    include LayerMixins::OGRQueryFilterMethods
    include LayerMixins::OGRSQLMethods

    FFI::OGR::Core::OGR_ALTER.constants.each do |_name, obj|
      const_set(obj.ruby_name, obj.value.to_i(16))
    end

    # @return [FFI::Pointer] C pointer to the C Layer.
    attr_reader :c_pointer

    # @param layer_ptr [FFI::Pointer]
    def initialize(layer_ptr)
      @c_pointer = layer_ptr
    end

    # @return [String]
    def name
      name, ptr = FFI::OGR::API.OGR_L_GetName(@c_pointer)
      ptr.autorelease = false

      name
    end

    # @return [Boolean]
    # TODO: This seems to occasionally lead to: 28352 illegal hardware
    #   instruction, and sometimes full crashes.
    def sync_to_disk
      OGR::ErrorHandling.handle_ogr_err('Unable to sync layer to disk') do
        FFI::OGR::API.OGR_L_SyncToDisk(@c_pointer)
      end
    end

    # Tests if this layer supports the given capability.  Must be in the list
    # of available capabilities.  See http://www.gdal.org/ogr__api_8h.html#a480adc8b839b04597f49583371d366fd.
    #
    # @param capability [String]
    # @return [Boolean]
    # @see http://www.gdal.org/ogr__api_8h.html#a480adc8b839b04597f49583371d366fd
    def test_capability(capability)
      FFI::OGR::API.OGR_L_TestCapability(@c_pointer, capability.to_s)
    end

    # NOTE: This SpatialReference is owned by the Layer and should thus not be
    # modified.
    #
    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_pointer = FFI::OGR::API.OGR_L_GetSpatialRef(@c_pointer)
      return nil if spatial_ref_pointer.null?

      OGR::SpatialReference.new(spatial_ref_pointer)
    end

    # @return [OGR::Envelope]
    def extent(force: true)
      envelope = FFI::OGR::Envelope.new
      FFI::OGR::API.OGR_L_GetExtent(@c_pointer, envelope, force)
      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # @return [OGR::Envelope]
    def extent_by_geometry(geometry_field_index, force: true)
      envelope = FFI::OGR::Envelope.new
      FFI::OGR::API.OGR_L_GetExtentEx(@c_pointer, geometry_field_index, envelope, force)
      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # @return [Symbol] One of OGRwkbGeometryType.
    def geometry_type
      FFI::OGR::API.OGR_L_GetGeomType(@c_pointer)
    end

    # @return [OGR::StyleTable, nil]
    def style_table
      style_table_pointer = FFI::OGR::API.OGR_L_GetStyleTable(@c_pointer)
      return nil if style_table_pointer.null?

      OGR::StyleTable.new(style_table_pointer)
    end

    # @param new_style_table [OGR::StyleTable, FFI::pointer]
    def style_table=(new_style_table)
      style_table_ptr = GDAL._pointer(OGR::StyleTable, new_style_table)
      raise OGR::Failure if style_table_ptr.nil? || style_table_ptr.null?

      FFI::OGR::API.OGR_L_SetStyleTable(@c_pointer, style_table_ptr)
    end
  end
end
