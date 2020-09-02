# typed: false
# frozen_string_literal: true

module OGR
  module LayerMixins
    module OGRFeatureMethods
      # The schema information for this layer.
      #
      # @return [OGR::FeatureDefinition,nil]
      def definition
        feature_defn_pointer = FFI::OGR::API.OGR_L_GetLayerDefn(@c_pointer)
        feature_defn_pointer.autorelease = false

        return nil if feature_defn_pointer.null?

        # This object should not be modified.
        OGR::FeatureDefinition.new(feature_defn_pointer)
      end
      alias feature_definition definition

      # Adds the new OGR::Feature to the Layer. The feature should have been
      # created using the Layer's FeatureDefintion.
      #
      #   feature = OGR::Feature.new(layer.feature_definition)
      #   feature.set_field_integer(123)
      #   layer.create_feature(feature)
      #
      # @param feature [OGR::Feature] [description]
      # @raise [OGR::Failure]
      def create_feature(feature)
        raise OGR::UnsupportedOperation, 'This layer does not support feature creation.' unless can_sequential_write?

        OGR::ErrorHandling.handle_ogr_err('Unable to create feature') do
          FFI::OGR::API.OGR_L_CreateFeature(@c_pointer, feature.c_pointer)
        end
      end

      # Deletes the feature from the layer.
      #
      # @param feature_id [Integer] ID of the Feature to delete.
      # @raise [OGR::Failure] When trying to delete a feature with an ID that
      #   does not exist.
      def delete_feature(feature_id)
        raise OGR::UnsupportedOperation, 'This layer does not support feature deletion.' unless can_delete_feature?

        OGR::ErrorHandling.handle_ogr_err("Unable to delete feature with ID '#{feature_id}'") do
          FFI::OGR::API.OGR_L_DeleteFeature(@c_pointer, feature_id)
        end
      end

      # The number of features in this layer.  If +force+ is false and it would be
      # expensive to determine the feature count, -1 may be returned.
      #
      # @param force [Boolean] Force the calculation even if it's expensive.
      # @return [Integer]
      def feature_count(force: true)
        FFI::OGR::API.OGR_L_GetFeatureCount(@c_pointer, force)
      end

      # Rewrites an existing feature using the ID within the given Feature.
      #
      # @param new_feature [OGR::Feature, FFI::Pointer]
      # @raise [OGR::Failure]
      def feature=(new_feature)
        raise OGR::UnsupportedOperation, '#feature= not supported by this Layer' unless can_random_write?

        new_feature_ptr = GDAL._pointer(OGR::Feature, new_feature)
        raise OGR::InvalidFeature if new_feature_ptr.nil? || new_feature_ptr.null?

        OGR::ErrorHandling.handle_ogr_err('Unable to set feature') do
          FFI::OGR::API.OGR_L_SetFeature(@c_pointer, new_feature_ptr)
        end
      end

      # @param index [Integer] The 0-based index of the feature to get.  It should
      #   be <= +feature_count+, but no checking is done to ensure.
      # @return [OGR::Feature, nil]
      def feature(index)
        raise OGR::UnsupportedOperation, '#feature(index) not supported by this Layer' unless can_random_read?

        # This feature needs to be Destroyed.
        feature_pointer = FFI::OGR::API.OGR_L_GetFeature(@c_pointer, index)
        return nil if feature_pointer.null?

        OGR::Feature.new(feature_pointer)
      end

      # The next available feature in this layer.  Only features matching the
      # current spatial filter will be returned.  Use +reset_reading+ to start at
      # the beginning again.
      #
      # NOTE: You *must* call {{OGR::Feature#destroy!}} on the returned feature,
      # otherwise expect segfaults.
      #
      # @return [OGR::Feature, nil]
      def next_feature
        feature_pointer = FFI::OGR::API.OGR_L_GetNextFeature(@c_pointer)
        return if feature_pointer.null?

        OGR::Feature.new(feature_pointer)
      end

      # Sets the index for #next_feature.
      #
      # @param feature_index [Integer]
      # @raise [OGR::Failure]
      def next_feature_index=(feature_index)
        OGR::ErrorHandling.handle_ogr_err("Unable to set next feature index to #{feature_index}") do
          FFI::OGR::API.OGR_L_SetNextByIndex(@c_pointer, feature_index)
        end
      end
      alias set_next_by_index next_feature_index=

      # @return [Integer]
      def features_read
        FFI::OGR::API.OGR_L_GetFeaturesRead(@c_pointer)
      end

      # Resets the sequential reading of features for this layer.
      def reset_reading
        FFI::OGR::API.OGR_L_ResetReading(@c_pointer)
      end
    end
  end
end
