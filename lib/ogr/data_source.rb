# typed: true
# frozen_string_literal: true

require 'uri'
require_relative '../gdal'
require_relative '../ogr'
require_relative 'data_source_mixins/capability_methods'
require_relative '../gdal/major_object'

module OGR
  class DataSource
    include GDAL::MajorObject
    include GDAL::Logger
    include DataSourceMixins::CapabilityMethods

    # Same as +.new+.
    #
    # @param path [String]
    # @param access_flag [String] 'r' for read, 'w', for write.
    # @return [OGR::DataSource]
    def self.open(path, access_flag = 'r')
      ds = new(path, access_flag)

      if block_given?
        result = yield ds
        ds.close
        result
      else
        ds
      end
    end

    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      return unless pointer && !pointer.null?

      FFI::OGR::API.OGR_DS_Destroy(pointer)
    end

    # Use to release the resulting data pointer from #execute_sql.
    #
    # @param pointer [FFI::Pointer]
    def self.release_result_set(data_source_pointer, layer_pointer)
      return unless data_source_pointer && !data_source_pointer.null? && layer_pointer && !layer_pointer.null?

      FFI::OGR::API.OGR_DS_ReleaseResultSet(data_source_pointer, layer_pointer)
    end

    # @return [FFI::Pointer]
    attr_reader :c_pointer

    # @param path_or_pointer [String, FFI::Pointer] Path/URL to the file to
    #   open or the Pointer to an already existing data soruce.
    # @param access_flag [String] 'r' for read, 'w', for write.
    def initialize(path_or_pointer, access_flag)
      @c_pointer =
        if path_or_pointer.is_a?(String)
          uri = URI.parse(path_or_pointer)
          file_path = uri.scheme.nil? ? ::File.expand_path(path_or_pointer) : path_or_pointer
          FFI::OGR::API.OGROpen(file_path, OGR._boolean_access_flag(access_flag), nil)
        else
          path_or_pointer
        end

      if @c_pointer.null?
        error_msg, ptr = FFI::CPL::Error.CPLGetLastErrorMsg
        ptr.autorelease = false

        error_type = FFI::CPL::Error.CPLGetLastErrorType
        FFI::CPL::Error.CPLErrorReset

        raise OGR::OpenFailure, "#{error_type}: #{error_msg} (#{file_path})"
      end

      @layers = []
    end

    # Closes opened data source and releases allocated resources.
    def destroy!
      DataSource.release(@c_pointer)

      @c_pointer = nil
    end
    alias close destroy!

    # Name of the file represented by this object.
    #
    # @return [String]
    def name
      # This is an internal string and should not be modified or freed.
      name_ptr = FFI::OGR::API.OGR_DS_GetName(@c_pointer)
      name_ptr.autorelease = false

      name_ptr.read_string_to_null
    end

    # @return [OGR::Driver]
    def driver
      driver_ptr = FFI::OGR::API.OGR_DS_GetDriver(@c_pointer)
      return nil if driver_ptr.nil?

      OGR::Driver.new(driver_ptr)
    end

    # @return [Integer]
    def layer_count
      FFI::OGR::API.OGR_DS_GetLayerCount(@c_pointer)
    end

    # @param index [Integer] 0-offset index of the layer to retrieve.
    # @return [OGR::Layer]
    def layer(index)
      @layers.fetch(index) do
        # The returned layer remains owned by the OGRDataSource and should not be deleted by the application.
        layer_pointer = FFI::OGR::API.OGR_DS_GetLayer(@c_pointer, index)
        layer_pointer.autorelease = false

        return nil if layer_pointer.null?

        l = OGR::Layer.new(layer_pointer)
        @layers.insert(index, l)

        l
      end
    end

    # @param name [String]
    # @return [OGR::Layer]
    def layer_by_name(name)
      # The returned layer remains owned by the OGRDataSource and should not be deleted by the application.
      layer_pointer = FFI::OGR::API.OGR_DS_GetLayerByName(@c_pointer, name)
      layer_pointer.autorelease = false

      return nil if layer_pointer.null?

      OGR::Layer.new(layer_pointer)
    end

    # @param name [String] The name for the new layer.
    # @param geometry_type [FFI::OGR::API::WKBGeometryType] Constrain to this
    #   geometry type.
    # @param spatial_reference [FFI::Pointer, OGR::SpatialReference] The coordinate system
    # @param options [Hash] Driver-specific options.
    # @return [OGR::Layer]
    def create_layer(name, geometry_type: :wkbUnknown, spatial_reference: nil, **options)
      raise OGR::UnsupportedOperation, 'This data source does not support creating layers.' unless can_create_layer?

      spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, spatial_reference, autorelease: false) if spatial_reference
      options_obj = GDAL::Options.pointer(options)

      layer_ptr =
        FFI::OGR::API.OGR_DS_CreateLayer(@c_pointer, name, spatial_ref_ptr, geometry_type, options_obj)

      raise OGR::InvalidLayer, "Unable to create layer '#{name}'." unless layer_ptr

      @layers << OGR::Layer.new(layer_ptr)

      @layers.last
    end

    # @param source_layer [OGR::Layer, FFI::Pointer]
    # @param new_name [String]
    # @param options [Hash]
    # @return [OGR::Layer, nil]
    def copy_layer(source_layer, new_name, **options)
      source_layer_ptr = GDAL._pointer(OGR::Layer, source_layer)
      options_ptr = GDAL::Options.pointer(options)

      layer_ptr = FFI::OGR::API.OGR_DS_CopyLayer(@c_pointer, source_layer_ptr,
                                                 new_name, options_ptr)
      return nil if layer_ptr.null?

      OGR::Layer.new(layer_ptr)
    end

    # @param index [Integer]
    # @raise [OGR::Failure]
    def delete_layer(index)
      raise OGR::UnsupportedOperation, 'This data source does not support deleting layers.' unless can_delete_layer?

      OGR::ErrorHandling.handle_ogr_err("Unable to delete layer at index #{index}") do
        FFI::OGR::API.OGR_DS_DeleteLayer(@c_pointer, index)
      end
    end

    # @param command [String] The SQL to execute.
    # @param spatial_filter [OGR::Geometry, FFI::Pointer]
    # @param dialect [String] Can pass in 'SQLITE' to use that instead of the
    #   default OGRSQL dialect.
    # @return [OGR::Layer, nil]
    # @see http://www.gdal.org/ogr_sql.html
    def execute_sql(command, spatial_filter = nil, dialect = nil)
      geometry_ptr = GDAL._pointer(OGR::Geometry, spatial_filter) if spatial_filter

      layer_ptr = FFI::OGR::API.OGR_DS_ExecuteSQL(@c_pointer, command, geometry_ptr, dialect)
      layer_ptr.autorelease = false

      return nil if layer_ptr.null?

      OGR::Layer.new(FFI::AutoPointer.new(layer_ptr, lambda { |ptr|
        DataSource.release_result_set(@c_pointer, ptr)
      }))
    end

    # @return [OGR::StyleTable, nil]
    def style_table
      style_table_ptr = FFI::OGR::API.OGR_DS_GetStyleTable(@c_pointer)
      style_table_ptr.autorelease = false

      return nil if style_table_ptr.null?

      OGR::StyleTable.new(style_table_ptr)
    end

    # @param new_style_table [OGR::StyleTable, FFI::Pointer]
    def style_table=(new_style_table)
      new_style_table_ptr = GDAL._pointer(OGR::StyleTable, new_style_table)

      FFI::OGR::API.OGR_DS_SetStyleTable(@c_pointer, new_style_table_ptr)

      if new_style_table.instance_of? OGR::StyleTable
        new_style_table
      else
        OGR::StyleTable.new(new_style_table_ptr)
      end
    end

    # @param capability [String] Must be one of: ODsCCreateLayer,
    #   ODsCDeleteLayer, ODsCCreateGeomFieldAfterCreateLayer,
    #   ODsCCurveGeometries.
    # @return [Boolean]
    def test_capability(capability)
      FFI::OGR::API.OGR_DS_TestCapability(@c_pointer, capability)
    end

    # @raise [OGR::Failure]
    def sync_to_disk
      OGR::ErrorHandling.handle_ogr_err('Unable to syn datasource to disk') do
        FFI::OGR::API.OGR_DS_SyncToDisk(@c_pointer)
      end
    end
  end
end
