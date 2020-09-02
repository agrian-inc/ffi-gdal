# typed: false
# frozen_string_literal: true

module OGR
  module GeometryMixins
    module Extensions
      # @return [Integer] The number of the UTM zone this geometry belongs to.
      def utm_zone
        return unless spatial_reference

        self_as4326 =
          if spatial_reference.authority_code == '4326'
            self
          else
            # Note: #clone here has overriden Ruby's clone and calls OGR_G_Clone;
            # it's important to do this and
            as4326 = clone
            return unless as4326.transform_to!(OGR::SpatialReference.new_from_epsg(4326))

            as4326
          end

        self_as4326.self_as4326.buffer!(0) unless valid?

        return unless self_as4326.point_on_surface.x

        ((self_as4326.point_on_surface.x + 180) / 6.to_f).floor + 1
      end

      # @return [Boolean]
      def container?
        self.class.ancestors.include? OGR::GeometryTypes::Container
      end

      # @return [Boolean]
      def curve?
        self.class.ancestors.include? OGR::GeometryTypes::Curve
      end

      # @return [Boolean]
      def surface?
        self.class.ancestors.include? OGR::GeometryTypes::Surface
      end

      def !=(other)
        !equals?(other)
      end

      def is_2d?
        coordinate_dimension == 2
      end

      def is_3d?
        coordinate_dimension == 3
      end

      # @return [Boolean]
      def invalid?
        !valid?
      end

      def collection?
        false
      end

      def to_vector(file_name, driver, layer_name: 'vectorized_geometry', spatial_reference: nil)
        driver = OGR::Driver.by_name(driver)

        data_source = driver.create_data_source(file_name)
        log "Creating layer #{layer_name}, type: #{type}"
        layer = data_source.create_layer(layer_name, geometry_type: type,
                                                     spatial_reference: spatial_reference)

        # field = FieldDefinition.new('Name', :OFTString)
        # field.width = 32

        raise OGR::InvalidLayer, "Unable to create layer '#{layer_name}'." unless layer

        feature = layer.create_feature(layer_name)
        feature.geometry = self

        data_source
      end
    end
  end
end
