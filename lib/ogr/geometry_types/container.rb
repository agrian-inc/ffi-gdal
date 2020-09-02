# typed: false
# frozen_string_literal: true

require_relative '../geometry_mixins/container_mixins'

module OGR
  module GeometryTypes
    module Container
      include OGR::GeometryMixins::ContainerMixins

      def collection?
        true
      end

      # If this geometry is a container, this adds +geometry+ to the container.
      # If this is a Polygon, +geometry+ must be a LinearRing.  If the Polygon is
      # empty, the first added +geometry+ will be the exterior ring.  Subsequent
      # geometries added will be interior rings.
      #
      # @param sub_geometry [OGR::Geometry, FFI::Pointer]
      # @raise [OGR::Failure]
      def add_geometry(sub_geometry)
        sub_geometry_ptr = GDAL._pointer(OGR::Geometry, sub_geometry)

        OGR::ErrorHandling.handle_ogr_err("Unable to add geometry: #{sub_geometry}") do
          FFI::OGR::API.OGR_G_AddGeometry(@c_pointer, sub_geometry_ptr)
        end
      end

      # @param sub_geometry [OGR::Geometry, FFI::Pointer]
      # @raise [OGR::Failure]
      def add_geometry_directly(sub_geometry)
        sub_geometry_ptr = GDAL._pointer(OGR::Geometry, sub_geometry, autorelease: false)

        OGR::ErrorHandling.handle_ogr_err("Unable to add geometry directly: #{sub_geometry}") do
          FFI::OGR::API.OGR_G_AddGeometryDirectly(@c_pointer, sub_geometry_ptr)
        end
      end

      # @param geometry_index [Integer]
      # @param delete [Boolean]
      # @raise [OGR::Failure]
      def remove_geometry(geometry_index, delete: true)
        msg = "Unable to add remove geometry at index #{geometry_index} (delete? #{delete})"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::API.OGR_G_RemoveGeometry(@c_pointer, geometry_index, delete)
        end
      end

      # If this geometry is a container, this fetches the geometry at the
      # sub_geometry_index.
      #
      # @param sub_geometry_index [Integer]
      # @return [OGR::Geometry]
      def geometry_at(sub_geometry_index)
        build_geometry do
          tmp_ptr = FFI::OGR::API.OGR_G_GetGeometryRef(@c_pointer, sub_geometry_index)
          tmp_ptr.autorelease = false
          tmp_ptr.null? ? nil : FFI::OGR::API.OGR_G_Clone(tmp_ptr)
        end
      end
      alias geometry_ref geometry_at

      # Build a ring from a bunch of arcs.  The collection must be
      # a MultiLineString or GeometryCollection.
      #
      # @param tolerance [Float]
      # @param auto_close [Boolean]
      # @return [OGR::Geometry]
      # @raise [OGR::Failure]
      def polygon_from_edges(tolerance, auto_close: false)
        best_effort = false

        ogrerr_ptr = FFI::MemoryPointer.new(:pointer)

        new_geometry_ptr = FFI::OGR::API.OGRBuildPolygonFromEdges(@c_pointer,
                                                                  best_effort,
                                                                  auto_close,
                                                                  tolerance,
                                                                  ogrerr_ptr)

        OGR::ErrorHandling.handle_ogr_err('Unable to create polygon from edges') do
          FFI::OGR::Core::Err[ogrerr_ptr.read_int]
        end

        OGR::Geometry.factory(new_geometry_ptr)
      end
    end
  end
end
