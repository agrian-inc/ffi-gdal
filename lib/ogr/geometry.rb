# typed: false
# frozen_string_literal: true

require_relative '../ogr'
require_relative 'geometry_mixins/extensions'
require_relative '../gdal'

module OGR
  module Geometry
    module ClassMethods
      def create(type)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateGeometry(type)
        return if geometry_pointer.null?

        geometry_pointer.autorelease = false

        factory(geometry_pointer)
      end

      # Creates a new Geometry using the class of the geometry that the type
      # represents.
      #
      # @param geometry [OGR::Geometry, FFI::Pointer]
      # @return [OGR::Geometry]
      def factory(geometry)
        geometry =
          if geometry.is_a?(OGR::Geometry)
            geometry
          else
            OGR::UnknownGeometry.new(geometry)
          end

        new_pointer = geometry.c_pointer
        return if new_pointer.nil? || new_pointer.null?

        case geometry.type
        when :wkbPoint then OGR::Point.new(new_pointer)
        when :wkbPoint25D then OGR::Point25D.new(new_pointer)
        when :wkbLineString
          if geometry.to_wkt =~ /^LINEARRING/
            OGR::LinearRing.new(new_pointer)
          else
            OGR::LineString.new(new_pointer)
          end
        when :wkbLineString25D then OGR::LineString25D.new(new_pointer)
        when :wkbLinearRing then OGR::LinearRing.new(new_pointer)
        when :wkbPolygon then OGR::Polygon.new(new_pointer)
        when :wkbPolygon25D then OGR::Polygon25D.new(new_pointer)
        when :wkbMultiPoint then OGR::MultiPoint.new(new_pointer)
        when :wkbMultiPoint25D then OGR::MultiPoint25D.new(new_pointer)
        when :wkbMultiLineString then OGR::MultiLineString.new(new_pointer)
        when :wkbMultiLineString25D then OGR::MultiLineString25D.new(new_pointer)
        when :wkbMultiPolygon then OGR::MultiPolygon.new(new_pointer)
        when :wkbMultiPolygon25D then OGR::MultiPolygon25D.new(new_pointer)
        when :wkbGeometryCollection then OGR::GeometryCollection.new(new_pointer)
        when :wkbGeometryCollection25D then OGR::GeometryCollection25D.new(new_pointer)
        when :wkbNone then OGR::NoneGeometry.new(new_pointer)
        else
          geometry
        end
      end

      # @param wkt_data [String]
      # @param spatial_ref [FFI::Pointer] Optional spatial reference
      #   to assign to the new geometry.
      # @return [OGR::Geometry]
      def create_from_wkt(wkt_data, spatial_ref = nil)
        wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
        wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
        wkt_pointer_pointer.write_pointer(wkt_data_pointer)

        spatial_ref_pointer = GDAL._pointer(OGR::SpatialReference, spatial_ref) if spatial_ref

        geometry_ptr = FFI::MemoryPointer.new(:pointer)
        geometry_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        geometry_ptr_ptr.write_pointer(geometry_ptr)

        FFI::OGR::API.OGR_G_CreateFromWkt(wkt_pointer_pointer,
                                          spatial_ref_pointer, geometry_ptr_ptr)

        return if geometry_ptr_ptr.null? || geometry_ptr_ptr.read_pointer.null?

        factory(geometry_ptr_ptr.read_pointer)
      end

      # @param wkb_data [String] Binary string of WKB.
      # @param spatial_ref [OGR::SpatialReference]
      # @return [OGR::Geometry]
      def create_from_wkb(wkb_data, spatial_ref = nil)
        wkb_data_pointer = FFI::MemoryPointer.new(:char, wkb_data.length)
        wkb_data_pointer.put_bytes(0, wkb_data)

        spatial_ref_pointer = GDAL._pointer(OGR::SpatialReference, spatial_ref) if spatial_ref

        geometry_ptr_ptr = GDAL._pointer_pointer(:pointer)

        byte_count = wkb_data.length
        FFI::OGR::API.OGR_G_CreateFromWkb(wkb_data_pointer, spatial_ref_pointer, geometry_ptr_ptr, byte_count)

        return if geometry_ptr_ptr.null? || geometry_ptr_ptr.read_pointer.null?

        factory(geometry_ptr_ptr.read_pointer)
      end

      # @param gml_data [String]
      # @return [OGR::Geometry]
      def create_from_gml(gml_data)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateFromGML(gml_data)

        _ = factory(geometry_pointer)
      end

      # @param json_data [String]
      # @return [OGR::Geometry]
      def create_from_json(json_data)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateGeometryFromJson(json_data)

        factory(geometry_pointer)
      end

      # The human-readable string for the geometry type.
      #
      # @param type [FFI::OGR::WKBGeometryType]
      # @return [String]
      def type_to_name(type)
        name, ptr = FFI::OGR::Core.OGRGeometryTypeToName(type)
        ptr.autorelease = false

        name
      end

      # Finds the most specific common geometry type from the two given types.
      # Useful when trying to figure out what geometry type to report for an
      # entire layer, when the layer uses multiple types.
      #
      # @param main [FFI::OGR::WKBGeometryType]
      # @param extra [FFI::OGR::WKBGeometryType]
      # @return [FFI::OGR::WKBGeometryType] Returns :wkbUnknown when there is
      #   no type in common.
      def merge_geometry_types(main, extra)
        FFI::OGR::Core.OGRMergeGeometryTypes(main, extra)
      end

      # @param pointer [FFI::Pointer]
      def release(pointer)
        return unless pointer && !pointer.null?

        FFI::OGR::API.OGR_G_DestroyGeometry(pointer)
      end
    end

    extend ClassMethods

    def self.included(base)
      base.send(:include, GDAL::Logger)
      base.send(:include, OGR::GeometryMixins::Extensions)
      base.send(:extend, ClassMethods)
    end

    #--------------------------------------------------------------------------
    # Instance Methods
    #--------------------------------------------------------------------------

    # @return [FFI::Pointer]
    attr_reader :c_pointer

    def destroy!
      self.class.release(@c_pointer)

      @c_pointer = nil
    end

    # @return [OGR::Geometry]
    def clone
      new_geometry_ptr = FFI::OGR::API.OGR_G_Clone(@c_pointer)

      OGR::Geometry.factory(new_geometry_ptr)
    end

    # Clears all information from the geometry.
    #
    # @return nil
    def empty!
      FFI::OGR::API.OGR_G_Empty(@c_pointer)
    end

    # @return [Integer] 0 for points, 1 for lines, 2 for surfaces.
    def dimension
      FFI::OGR::API.OGR_G_GetDimension(@c_pointer)
    end

    # The dimension of coordinates in this geometry (i.e. 2d vs 3d).
    #
    # @return [Integer] 2 or 3, but 0 in the case of an empty point.
    def coordinate_dimension
      FFI::OGR::API.OGR_G_GetCoordinateDimension(@c_pointer)
    end

    # @param new_coordinate_dimension [Integer]
    def coordinate_dimension=(new_coordinate_dimension)
      unless [2, 3].include?(new_coordinate_dimension)
        raise "Can't set coordinate to #{new_coordinate_dimension}.  Must be 2 or 3."
      end

      FFI::OGR::API.OGR_G_SetCoordinateDimension(@c_pointer, new_coordinate_dimension)
    end

    # @return [OGR::Envelope]
    def envelope
      case coordinate_dimension
      when 2
        envelope = FFI::OGR::Envelope.new
        FFI::OGR::API.OGR_G_GetEnvelope(@c_pointer, envelope)
      when 3
        envelope = FFI::OGR::Envelope3D.new
        FFI::OGR::API.OGR_G_GetEnvelope3D(@c_pointer, envelope)
      when 0 then return nil
      else
        raise 'Unknown envelope dimension.'
      end

      return if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def type
      FFI::OGR::API.OGR_G_GetGeometryType(@c_pointer)
    end

    # @return [String]
    def type_to_name
      self.class.type_to_name(type)
    end

    # @return [String]
    def name
      # The returned pointer is to a static internal string and should not be modified or freed.
      name, ptr = FFI::OGR::API.OGR_G_GetGeometryName(@c_pointer)
      ptr.autorelease = false

      name
    end

    # @return [Integer]
    def geometry_count
      FFI::OGR::API.OGR_G_GetGeometryCount(@c_pointer)
    end
    alias count geometry_count

    # @return [Integer]
    def point_count
      return 0 if empty?

      FFI::OGR::API.OGR_G_GetPointCount(@c_pointer)
    end

    # @return [Integer]
    def centroid
      point = is_3d? ? OGR::Point25D.new : OGR::Point.new

      ogr_err = FFI::OGR::API.OGR_G_Centroid(@c_pointer, point.c_pointer)
      return if point.c_pointer.null? || ogr_err.positive?

      point
    end

    # Dump as WKT to the given +file_path+; dumps to STDOUT if none is given.
    #
    # @param file_path [String] The text file to write to.
    # @param prefix [String] The prefix to put on each line of output.
    def dump_readable(file_path = nil, prefix: nil)
      file_ptr = file_path ? FFI::CPL::Conv.CPLOpenShared(file_path, 'w', false) : nil
      FFI::OGR::API.OGR_G_DumpReadable(@c_pointer, file_ptr, prefix)
      FFI::CPL::Conv.CPLCloseShared(file_ptr) if file_ptr
    end

    # Converts this geometry to a 2D geometry.
    def flatten_to_2d!
      FFI::OGR::API.OGR_G_FlattenTo2D(@c_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def intersects?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Intersects(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def equals?(geometry)
      return false unless geometry.is_a? OGR::Geometry

      FFI::OGR::API.OGR_G_Equals(@c_pointer, geometry.c_pointer)
    end
    alias == equals?

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def disjoint?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Disjoint(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def touches?(geometry)
      FFI::OGR::API.OGR_G_Touches(@c_pointer, geometry.c_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def crosses?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Crosses(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def within?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Within(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def contains?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Contains(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def overlaps?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Overlaps(@c_pointer, geometry_ptr)
    end

    # @return [Boolean]
    def empty?
      FFI::OGR::API.OGR_G_IsEmpty(@c_pointer)
    end

    # @return [Boolean]
    def valid?
      FFI::OGR::API.OGR_G_IsValid(@c_pointer)
    rescue GDAL::Error
      false
    end

    # Returns TRUE if the geometry has no anomalous geometric points, such as
    # self intersection or self tangency. The description of each instantiable
    # geometric class will include the specific conditions that cause an
    # instance of that class to be classified as not simple.
    #
    # @return [Boolean]
    def simple?
      FFI::OGR::API.OGR_G_IsSimple(@c_pointer)
    end

    # TRUE if the geometry has no points, otherwise FALSE.
    #
    # @return [Boolean]
    def ring?
      FFI::OGR::API.OGR_G_IsRing(@c_pointer)
    rescue GDAL::Error => e
      return false if e.message.include? 'IllegalArgumentException'

      raise
    end

    # @param other_geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def intersection(other_geometry)
      build_geometry do
        FFI::OGR::API.OGR_G_Intersection(@c_pointer, other_geometry.c_pointer)
      end
    end

    # @param other_geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def union(other_geometry)
      build_geometry do
        FFI::OGR::API.OGR_G_Union(@c_pointer, other_geometry.c_pointer)
      end
    end

    # If this or any contained geometries has polygon rings that aren't closed,
    # this closes them by adding the starting point at the end.
    def close_rings!
      FFI::OGR::API.OGR_G_CloseRings(@c_pointer)
    end

    # Creates a polygon from a set of sparse edges.  The newly created geometry
    # will contain a collection of reassembled Polygons.
    #
    # @return [OGR::Geometry] nil if the current geometry isn't a
    #   MultiLineString or if it's impossible to reassemble due to topological
    #   inconsistencies.
    def polygonize
      build_geometry { FFI::OGR::API.OGR_G_Polygonize(@c_pointer) }
    end

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def difference(geometry)
      new_geometry_ptr = FFI::OGR::API.OGR_G_Difference(@c_pointer, geometry.c_pointer)
      return if new_geometry_ptr.null?

      self.class.factory(new_geometry_ptr)
    end
    alias - difference

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def symmetric_difference(geometry)
      new_geometry_ptr = FFI::OGR::API.OGR_G_SymDifference(@c_pointer, geometry.c_pointer)
      return if new_geometry_ptr.null?

      self.class.factory(new_geometry_ptr)
    end

    # The shortest distance between the two geometries.
    #
    # @param geometry [OGR::Geometry]
    # @return [Float] -1 if an error occurs.
    def distance_to(geometry)
      FFI::OGR::API.OGR_G_Distance(@c_pointer, geometry.c_pointer)
    end

    # NOTE: The returned object may be shared with many geometries, and should
    # thus not be modified.
    #
    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_ptr = FFI::OGR::API.OGR_G_GetSpatialReference(@c_pointer)
      return if spatial_ref_ptr.null?

      OGR::SpatialReference.new(spatial_ref_ptr)
    end

    # Assigns a spatial reference to this geometry.  Any existing spatial
    # reference is replaced, but this does not reproject the geometry.
    #
    # @param new_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    def spatial_reference=(new_spatial_ref)
      #  Note that assigning a spatial reference increments the reference count
      #  on the OGRSpatialReference, but does not copy it.
      new_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_ref, autorelease: false)

      FFI::OGR::API.OGR_G_AssignSpatialReference(@c_pointer, new_spatial_ref_ptr)
    end

    # Transforms the coordinates of this geometry in its current spatial
    # reference system to a new spatial reference system.  Normally this means
    # reprojecting the vectors, but it could also include datum shifts, and
    # changes of units.
    #
    # Note that this doesn't require the geometry to have an existing spatial
    # reference system.
    #
    # @param coordinate_transformation [OGR::CoordinateTransformation,
    #   FFI::Pointer]
    # @raise [OGR::Failure]
    def transform!(coordinate_transformation)
      coord_trans_ptr = GDAL._pointer(OGR::CoordinateTransformation,
                                      coordinate_transformation)

      return if coord_trans_ptr.nil? || coord_trans_ptr.null?

      OGR::ErrorHandling.handle_ogr_err('Unable to transform geometry') do
        FFI::OGR::API.OGR_G_Transform(@c_pointer, coord_trans_ptr)
      end
    end

    # Similar to +#transform+, but this only works if the geometry already has an
    # assigned spatial reference system _and_ is transformable to the target
    # coordinate system.
    #
    # Because this function requires internal creation and initialization of an
    # OGRCoordinateTransformation object it is significantly more expensive to
    # use this function to transform many geometries than it is to create the
    # OGRCoordinateTransformation in advance, and call transform() with that
    # transformation. This function exists primarily for convenience when only
    # transforming a single geometry.
    #
    # @param new_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    # @raise [OGR::Failure]
    def transform_to!(new_spatial_ref)
      new_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_ref, autorelease: false)
      return if new_spatial_ref_ptr.null?

      OGR::ErrorHandling.handle_ogr_err('Unable to transform geometry') do
        FFI::OGR::API.OGR_G_TransformTo(@c_pointer, new_spatial_ref_ptr)
      end
    end

    # Computes and returns a new, simplified geometry.
    #
    # @param distance_tolerance [Float]
    # @param preserve_topology [Boolean]
    # @return [OGR::Geometry]
    def simplify(distance_tolerance, preserve_topology: false)
      build_geometry do
        if preserve_topology
          FFI::OGR::API.OGR_G_SimplifyPreserveTopology(@c_pointer, distance_tolerance)
        else
          FFI::OGR::API.OGR_G_Simplify(@c_pointer, distance_tolerance)
        end
      end
    end

    # Modify the geometry so that it has no segments longer than +max_length+.
    #
    # @param max_length [Float]
    # @return [OGR::Geometry] Returns self that's been segmentized.
    def segmentize!(max_length)
      FFI::OGR::API.OGR_G_Segmentize(@c_pointer, max_length)

      self
    end

    # @return [OGR::Geometry]
    def boundary
      build_geometry { FFI::OGR::API.OGR_G_Boundary(@c_pointer) }
    end

    # Computes the buffer of the geometry by building a new geometry that
    # contains the buffer region around the geometry that this was called on.
    #
    # @param distance [Float] The buffer distance to be applied.
    # @param quad_segments [Integer] The number of segments to use to approximate
    #   a 90 degree (quadrant) of curvature.
    # @return [OGR::Polygon]
    def buffer(distance, quad_segments = 30)
      build_geometry do
        FFI::OGR::API.OGR_G_Buffer(@c_pointer, distance, quad_segments)
      end
    end

    # @return [OGR::Geometry]
    def convex_hull
      build_geometry { FFI::OGR::API.OGR_G_ConvexHull(@c_pointer) }
    end

    # Returns a point that's guaranteed to lie on the surface.
    #
    # @return [OGR::Point]
    def point_on_surface
      build_geometry { FFI::OGR::API.OGR_G_PointOnSurface(@c_pointer) }
    end

    # @param wkb_data [String] Binary WKB data.
    # @raise [OGR::Failure]
    def import_from_wkb(wkb_data)
      OGR::ErrorHandling.handle_ogr_err('Unable to import geometry from WKB') do
        FFI::OGR::API.OGR_G_ImportFromWkb(@c_pointer, wkb_data, wkb_data.length)
      end
    end

    # The exact number of bytes required to hold the WKB of this object.
    #
    # @return [Integer]
    def wkb_size
      FFI::OGR::API.OGR_G_WkbSize(@c_pointer)
    end

    # @return [String]
    # @raise [OGR::Failure]
    def to_wkb(byte_order = :wkbXDR)
      output = FFI::MemoryPointer.new(:uchar, wkb_size)

      OGR::ErrorHandling.handle_ogr_err("Unable to export geometry to WKB (using byte order #{byte_order})") do
        FFI::OGR::API.OGR_G_ExportToWkb(@c_pointer, byte_order, output)
      end

      output.read_bytes(wkb_size)
    end

    # @param wkt_data [String]
    # @raise [OGR::Failure]
    def import_from_wkt(wkt_data)
      wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
      wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
      wkt_pointer_pointer.write_pointer(wkt_data_pointer)

      OGR::ErrorHandling.handle_ogr_err("Unable to import from WKT: #{wkt_data}") do
        FFI::OGR::API.OGR_G_ImportFromWkt(@c_pointer, wkt_pointer_pointer)
      end
    end

    # @return [String]
    # @raise [OGR::Failure]
    def to_wkt
      GDAL._cpl_read_and_free_string do |output_ptr|
        OGR::ErrorHandling.handle_ogr_err('Unable to export to WKT') do
          FFI::OGR::API.OGR_G_ExportToWkt(@c_pointer, output_ptr)
        end
      end
    end

    # This geometry expressed as GML in GML basic data types.
    #
    # @param [Hash] options
    # @option options [String] :format "GML3" is really the only "option" here,
    #   since without passing this in, GDAL defaults to "GML2.1.2" (as of 1.8.0).
    # @option options [String] :gml3_linestring_element "curve" is the only
    #   option here, which only pertains a) to LineString geometries, and b)
    #   when +:format+ is set to GML3.
    # @option options [String] :gml3_longsrs Defaults to "YES", which prefixes
    #   the EPSG authority with "urn:ogc:def:crs:EPSG::".  If "NO", the EPSG
    #   authority is prefixed with "EPSG:".
    # @option options [String] :gmlid Use this to write a gml:id attribute at
    #   the top level of the geometry.
    # @return [String]
    def to_gml(**options)
      options_ptr = GDAL::Options.pointer(options)
      gml, ptr = FFI::OGR::API.OGR_G_ExportToGMLEx(@c_pointer, options_ptr)
      FFI::CPL::VSI.VSIFree(ptr)

      gml
    end

    # @param altitude_mode [String] Value to write in the +altitudeMode+
    #   element.
    # @return [String]
    def to_kml(altitude_mode = nil)
      kml, ptr = FFI::OGR::API.OGR_G_ExportToKML(@c_pointer, altitude_mode)
      FFI::CPL::VSI.VSIFree(ptr)

      kml
    end

    # @return [String]
    def to_geo_json
      json, ptr = FFI::OGR::API.OGR_G_ExportToJson(@c_pointer)
      FFI::CPL::VSI.VSIFree(ptr)

      json
    end

    # Converts the current geometry to a LineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_line_string
      build_geometry { FFI::OGR::API.OGR_G_ForceToLineString(clone.c_pointer) }
    end

    # Since GDAL doesn't provide converting to a LinearRing, this is a hackish
    # method for doing so.
    #
    # @return [OGR::LinearRing]
    def to_linear_ring(close_rings: false)
      line_string = to_line_string

      return line_string unless line_string.is_a?(OGR::LineString)

      linear_ring = OGR::LinearRing.new

      linear_ring.spatial_reference = line_string.spatial_reference.clone if line_string.spatial_reference

      linear_ring.import_from_wkt(line_string.to_wkt.tr('LINESTRING', 'LINEARRING'))
      linear_ring.close_rings! if close_rings

      linear_ring
    end

    # Converts the current geometry to a Polygon geometry.  The returned object
    # is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_polygon
      build_geometry { FFI::OGR::API.OGR_G_ForceToPolygon(clone.c_pointer) }
    end

    # Converts the current geometry to a MultiPoint geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_point
      build_geometry { FFI::OGR::API.OGR_G_ForceToMultiPoint(clone.c_pointer) }
    end

    # Converts the current geometry to a MultiLineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_line_string
      build_geometry { FFI::OGR::API.OGR_G_ForceToMultiLineString(clone.c_pointer) }
    end

    # Converts the current geometry to a MultiPolygon geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::MultiPolygon]
    def to_multi_polygon
      build_geometry { FFI::OGR::API.OGR_G_ForceToMultiPolygon(@c_pointer) }
    end

    private

    # @param geometry_ptr [OGR::Geometry, FFI::Pointer]
    def initialize_from_pointer(geometry_ptr)
      raise OGR::InvalidHandle, "Must initialize with a valid pointer: #{geometry_ptr}" if geometry_ptr.nil?

      pointer = GDAL._pointer(OGR::Geometry, geometry_ptr, autorelease: false)

      raise OGR::InvalidHandle, "Must initialize with a valid pointer: #{geometry_ptr}" if pointer.null?

      @c_pointer = pointer
    end

    def build_geometry
      new_geometry_ptr = yield
      return if new_geometry_ptr.nil? || new_geometry_ptr.null? || new_geometry_ptr == @c_pointer

      OGR::Geometry.factory(new_geometry_ptr)
    end
  end
end
