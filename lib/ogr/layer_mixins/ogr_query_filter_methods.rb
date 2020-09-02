# typed: true
# frozen_string_literal: true

module OGR
  module LayerMixins
    module OGRQueryFilterMethods
      # TODO: per the GDAL docs: "The returned pointer is to an internally owned
      # object, and should not be altered or deleted by the caller."
      #
      # @return [OGR::Geometry]
      def spatial_filter
        filter_pointer = FFI::OGR::API.OGR_L_GetSpatialFilter(@c_pointer)
        return nil if filter_pointer.null?

        OGR::Geometry.factory(filter_pointer)
      end

      # @param new_spatial_filter [OGR::Geometry, FFI::Pointer]
      def spatial_filter=(new_spatial_filter)
        spatial_filter_ptr = GDAL._pointer(OGR::Geometry, new_spatial_filter)

        FFI::OGR::API.OGR_L_SetSpatialFilter(@c_pointer, spatial_filter_ptr)
      end

      # Only feature which intersect the filter geometry will be returned.
      #
      # @param geometry_field_index [Integer] The spatial filter operates on this
      #   geometry field.
      # @param geometry [OGR::Geometry] Use this geometry as the filtering
      #   region.
      def set_spatial_filter_ex(geometry_field_index, geometry)
        geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)

        FFI::OGR::API.OGR_L_SetSpatialFilterEx(
          @c_pointer, geometry_field_index, geometry_ptr
        )
      end

      # Only features that geometrically intersect the given rectangle will be
      # returned.  X/Y values should be in the same coordinate system as the
      # layer as a whole (different from #set_spatial_filter_rectangle_ex).  To
      # clear the filter, set #spatial_filter = nil.
      #
      # @param min_x [Float]
      # @param min_y [Float]
      # @param max_x [Float]
      # @param max_y [Float]
      def set_spatial_filter_rectangle(min_x, min_y, max_x, max_y)
        FFI::OGR::API.OGR_L_SetSpatialFilterRect(
          @c_pointer,
          min_x,
          min_y,
          max_x,
          max_y
        )
      end

      # Only features that geometrically intersect the given rectangle will be
      # returned.  X/Y values should be in the same coordinate system as the
      # layer as the given  GeometryFieldDefinition at the given index (different
      # from #set_spatial_filter_rectangle).  To clear the filter, set
      # #spatial_filter = nil.
      #
      # @param geometry_field_index [Integer]
      # @param min_x [Float]
      # @param min_y [Float]
      # @param max_x [Float]
      # @param max_y [Float]
      def set_spatial_filter_rectangle_ex(geometry_field_index, min_x, min_y, max_x, max_y)
        FFI::OGR::API.OGR_L_SetSpatialFilterRectEx(
          @c_pointer,
          geometry_field_index,
          min_x,
          min_y,
          max_x,
          max_y
        )
      end

      # Sets the attribute query string to be used when fetching Features using
      # #next_feature.  Should be in the form of an `SQL WHERE` clause.  Note
      # that this will generally result in resetting the current reading position.
      #
      # @param query [String]
      # @see http://ogdi.sourceforge.net/prop/6.2.CapabilitiesMetadata.html
      # @raise [OGR::Failure]
      def set_attribute_filter(query) # rubocop:disable Naming/AccessorMethodName
        OGR::ErrorHandling.handle_ogr_err("Unable to set attribute filter: #{query}") do
          FFI::OGR::API.OGR_L_SetAttributeFilter(@c_pointer, query)
        end
      end
    end
  end
end
