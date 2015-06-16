module OGR
  module GeometryTypes
    module Container
      def collection?
        true
      end

      # If this geometry is a container, this adds +geometry+ to the container.
      # If this is a Polygon, +geometry+ must be a LinearRing.  If the Polygon is
      # empty, the first added +geometry+ will be the exterior ring.  Subsequent
      # geometries added will be interior rings.
      #
      # @param sub_geometry [OGR::Geometry, FFI::Pointer]
      # @return +true+ if successful, otherwise raises an OGR exception.
      def add_geometry(sub_geometry)
        sub_geometry_ptr = GDAL._pointer(OGR::Geometry, sub_geometry)
        ogr_err = FFI::OGR::API.OGR_G_AddGeometry(@c_pointer, sub_geometry_ptr)

        ogr_err.handle_result "Unable to add geometry: #{sub_geometry}"
      end

      # @param sub_geometry [OGR::Geometry, FFI::Pointer]
      # @return +true+ if successful, otherwise raises an OGR exception.
      def add_directly(sub_geometry)
        sub_geometry_ptr = GDAL._pointer(OGR::Geometry, sub_geometry)
        ogr_err = FFI::OGR::API.OGR_G_AddGeometryDirectly(@c_pointer, sub_geometry_ptr)

        ogr_err.handle_result
      end

      # @param geometry_index [Fixnum]
      # @param delete [Boolean]
      # @return +true+ if successful, otherwise raises an OGR exception.
      def remove_geometry(geometry_index, delete = true)
        ogr_err = FFI::OGR::API.OGR_G_RemoveGeometry(@c_pointer, geometry_index, delete)

        ogr_err.handle_result
      end

      # If this geometry is a container, this fetches the geometry at the
      # sub_geometry_index.
      #
      # @param sub_geometry_index [Fixnum]
      # @return [OGR::Geometry]
      def geometry_at(sub_geometry_index)
        build_geometry do |ptr|
          FFI::OGR::API.OGR_G_GetGeometryRef(ptr, sub_geometry_index)
        end
      end

      # Build a ring from a bunch of arcs.  The collection must be
      # a MultiLineString or GeometryCollection.
      #
      # @param tolerance [Float]
      # @param auto_close [Boolean]
      # @return [OGR::Geometry]
      def polygon_from_edges(tolerance, auto_close: false)
        best_effort = false
        ogrerr_ptr = FFI::MemoryPointer.new(:pointer)

        new_geometry_ptr = FFI::OGR::API.OGRBuildPolygonFromEdges(@c_pointer,
          best_effort,
          auto_close,
          tolerance,
          ogrerr_ptr)

        ogrerr_int = ogrerr_ptr.read_int
        ogrerr = FFI::OGR::Core::Err[ogrerr_int]
        ogrerr.handle_result "Couldn't create polygon"

        OGR::Geometry.factory(new_geometry_ptr)
      end
    end
  end
end