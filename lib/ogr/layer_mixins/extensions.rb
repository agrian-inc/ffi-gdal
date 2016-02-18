require 'json'

module OGR
  module LayerMixins
    # Methods not part of the C Layer API.
    module Extensions
      # Enumerates through all associated features. Beware: it calls
      # {#reset_reading} both before and after it's called. If you're using
      # {OGR::Layer#next_feature} for iterating through features somewhere in
      # your code, this will reset that reading.
      #
      # @return [Enumerator]
      # @yieldparam [OGR::Feature]
      def each_feature
        return enum_for(:each_feature) unless block_given?

        reset_reading

        loop do
          break unless feature = next_feature

          begin
            yield feature
          ensure
            feature.destroy!
          end
        end

        reset_reading
      end

      # @return [Enumerator]
      # @yieldparam [FFI::Pointer] A pointer to each feature in the layer.
      def each_feature_pointer
        reset_reading

        loop do
          feature_ptr = FFI::OGR::API.OGR_L_GetNextFeature(@c_pointer)
          break if feature_ptr.null?
          yield feature_ptr
        end

        reset_reading
      end

      # @return [Array<OGR::Feature>]
      def features
        each_feature.to_a
      end

      # @return [OGR::Polygon] A polygon derived from a LinearRing that connects
      #   the 4 bounding box points (from the extent).
      def geometry_from_extent
        ring = OGR::LinearRing.new

        ring.point_count = 5
        ring.set_point(0, extent.x_min, extent.y_min)
        ring.set_point(1, extent.x_min, extent.y_max)
        ring.set_point(2, extent.x_max, extent.y_max)
        ring.set_point(3, extent.x_max, extent.y_min)
        ring.set_point(4, extent.x_min, extent.y_min)

        polygon = OGR::Polygon.new spatial_reference: spatial_reference.dup
        polygon.add_geometry(ring)

        polygon
      end

      # Iterates through all geometries in the Layer and extracts the point
      # values to an Array. The result will be an Array of Arrays where the
      # inner Array is the point values. If +with_attributes+ is given, it will
      # extract the field values for each given field names.
      #
      # @example Not passing +with_attributes+
      #   points = layer.point_values
      #   # => [[100, 100], [100, 120], [110, 110], [110, 100], [100, 100]]
      #
      # @example With +with_attributes+
      #   points = layer.point_values('Moisture' => :double, 'Color' => :string)
      #   # => [[100, 100, 74.2, 'Red'],
      #         [100, 120, 19.0, 'Blue'],
      #         [110, 110, 21.1, 'Red'],
      #         [110, 100, 54.99, 'Green'],
      #         [100, 100, 3.3, 'Red']]
      #
      # @param with_attributes [String, Array<String>]
      # @return [Array<Array>]
      # @raise [OGR::UnsupportedGeometryType] if a geometry of some type is
      #   encountered that the method doesn't know how to extract point values
      #   from.
      def point_values(with_attributes = {})
        return [[]] if feature_count.zero?

        field_indices = with_attributes.keys.map { |field_name| find_field_index(field_name) }
        values = Array.new(feature_count) { Array.new(2 + with_attributes.size) }
        start = Time.now
        i = 0

        # Initing these once and only once in the case the geom type is _not_
        # wkbPoint.
        x_ptr = FFI::MemoryPointer.new(:double)
        y_ptr = FFI::MemoryPointer.new(:double)

        each_feature_pointer do |feature_ptr|
          field_values = field_indices.map.with_index do |j, attribute_index|
            FFI::OGR::API.send("OGR_F_GetFieldAs#{with_attributes.values[attribute_index].capitalize}", feature_ptr, j)
          end

          geom_ptr = FFI::OGR::API.OGR_F_GetGeometryRef(feature_ptr)
          FFI::OGR::API.OGR_G_FlattenTo2D(geom_ptr)

          geom_type = FFI::OGR::API.OGR_G_GetGeometryType(geom_ptr)
          case geom_type
          when :wkbPoint
            values[i] = collect_point_values(geom_ptr, field_values)
            i += 1
          when :wkbLineString, :wkbLinearRing
            extract_ring_points(geom_ptr, x_ptr, y_ptr) do |points|
              values[i] = points.push(*field_values)
              i += 1
            end
          when :wkbPolygon
            exterior_ring_ptr = FFI::OGR::API.OGR_G_GetGeometryRef(geom_ptr, 0)

            extract_ring_points(exterior_ring_ptr, x_ptr, y_ptr) do |points|
              values[i] = points.push(*field_values)
              i += 1
            end

            count = FFI::OGR::API.OGR_G_GetGeometryCount(geom_ptr)
            next if count > 1

            count.times do |ring_num|
              next if ring_num.zero?
              ring_ptr = FFI::OGR::API.OGR_G_GetGeometryRef(geom_ptr, ring_num)

              extract_ring_points(ring_ptr, x_ptr, y_ptr) do |points|
                values[i] = points.push(*field_values)
                i += 1
              end
            end
          when :wkbMultiPoint, :wkbMultiLineString
            count = FFI::OGR::API.OGR_G_GetGeometryCount(geom_ptr)

            count.times do |geom_num|
              ring_ptr = FFI::OGR::API.OGR_G_GetGeometryRef(geom_ptr, geom_num)

              extract_ring_points(ring_ptr, x_ptr, y_ptr) do |points|
                values[i] = points.push(*field_values)
                i += 1
              end
            end
          when :wkbMultiPolygon
            polygon_count = FFI::OGR::API.OGR_G_GetGeometryCount(geom_ptr)

            polygon_count.times do |polygon_num|
              polygon_ptr = FFI::OGR::API.OGR_G_GetGeometryRef(geom_ptr, polygon_num)
              exterior_ring_ptr = FFI::OGR::API.OGR_G_GetGeometryRef(polygon_ptr, 0)

              extract_ring_points(exterior_ring_ptr, x_ptr, y_ptr) do |points|
                values[i] = points.push(*field_values)
                i += 1
              end

              count = FFI::OGR::API.OGR_G_GetGeometryCount(polygon_ptr)
              next if count > 1

              count.times do |ring_num|
                next if ring_num.zero?
                ring_ptr = FFI::OGR::API.OGR_G_GetGeometryRef(polygon_ptr, ring_num)

                extract_ring_points(ring_ptr, x_ptr, y_ptr) do |points|
                  values[i] = points.push(*field_values)
                  i += 1
                end
              end
            end
          else fail OGR::UnsupportedGeometryType,
            "Not sure how to extract point_values for a #{geom_type}"
          end
        end

        log "#point_values took #{Time.now - start}s"

        values
      end

      # Iterates through features to see if any of them are 3d.
      #
      # @return [Boolean]
      def any_geometries_with_z?
        found_z_geom = false

        each_feature_pointer do |feature_ptr|
          break if found_z_geom
          geom_ptr = FFI::OGR::API.OGR_F_GetGeometryRef(feature_ptr)
          coordinate_dimension = FFI::OGR::API.OGR_G_GetCoordinateDimension(geom_ptr)
          found_z_geom = coordinate_dimension == 3
        end

        found_z_geom
      end

      # @return [Hash]
      def as_json(options = nil)
        {
          layer: {
            extent: extent.as_json(options),
            feature_count: feature_count,
            feature_definition: feature_definition.as_json(options),
            features: features.map(&:as_json),
            fid_column: fid_column,
            geometry_column: geometry_column,
            geometry_type: geometry_type,
            name: name,
            spatial_reference: spatial_reference ? spatial_reference.as_json(options) : nil,
            style_table: style_table ? style_table.as_json(options) : nil
          },
          metadata: nil # all_metadata
        }
      end

      # @return [String]
      def to_json(options = nil)
        as_json(options).to_json
      end

      private

      # @param geometry_ptr [FFI::Pointer]
      # @param field_values [Array]
      # @return [Array]
      def collect_point_values(geometry_ptr, field_values)
        [FFI::OGR::API.OGR_G_GetX(geometry_ptr, 0), FFI::OGR::API.OGR_G_GetY(geometry_ptr, 0), *field_values]
      end

      # @param ring_ptr [FFI::Pointer] Pointer to the LineString/LinearRing to
      #   extract points from.
      # @param x_ptr [FFI::Pointer] Pointer to use for writing the x value to.
      # @param y_ptr [FFI::Pointer] Pointer to use for writing the y value to.
      # @yieldparam [Array<Float>] (x, y)
      def extract_ring_points(ring_ptr, x_ptr, y_ptr)
        FFI::OGR::API.OGR_G_GetPointCount(ring_ptr).times do |point_num|
          FFI::OGR::API.OGR_G_GetPoint(ring_ptr, point_num, x_ptr, y_ptr, nil)

          yield [x_ptr.read_double, y_ptr.read_double]

          x_ptr.clear
          y_ptr.clear
        end
      end
    end
  end
end
