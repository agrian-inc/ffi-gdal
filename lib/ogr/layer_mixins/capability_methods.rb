# typed: false
# frozen_string_literal: true

module OGR
  module LayerMixins
    # Helper methods for checking what the Layer is capable of.
    module CapabilityMethods
      # @return [Boolean] +true+ if #feature() is implemented in an optimized
      #   manner for this layer (as opposed to using #next_feature and
      #   #reset_reading).
      def can_random_read?
        test_capability('RandomRead')
      end

      # @return [Boolean] +true+ if #create_feature is allowed on this layer.
      def can_sequential_write?
        test_capability('SequentialWrite')
      end

      # @return [Boolean] +true+ if #feature= is allowed on this layer.
      def can_random_write?
        test_capability('RandomWrite')
      end

      # @return [Boolean] +true+ if this layer implements spatial filtering
      #   efficiently. This can be used as a clue by the application whether
      #   it should build and maintain its own spatial index for features in
      #   this layer.
      def can_fast_spatial_filter?
        test_capability('FastSpatialFilter')
      end

      # @return [Boolean] +true+ if this layer can return a feature count
      #   efficiently (i.e. without counting all of the features).
      def can_fast_feature_count?
        test_capability('FastFeatureCount')
      end

      # @return [Boolean] +true+ if this Layer can return its extent
      #   efficiently (i.e. without scanning all of the features.).
      def can_fast_get_extent?
        test_capability('FastGetExtent')
      end

      # @return [Boolean] +true+ if this layer can perform the
      #   #next_feature_index= call efficiently.
      def can_fast_set_next_by_index?
        test_capability('FastSetNextByIndex')
      end

      # @return [Boolean] +true+ if new Fields can be created on this Layer.
      def can_create_field?
        test_capability('CreateField')
      end

      # @return [Boolean] +true+ if the Layer supports creating new geometry
      #   fields on the current layer.
      def can_create_geometry_field?
        test_capability('CreateGeomField')
      end

      # @return [Boolean] +true+ if the Layer supports deleting existing fields
      #   on the current layer.
      def can_delete_field?
        test_capability('DeleteField')
      end

      # @return [Boolean] +true+ if the Layer supports reording fields on the
      #   current layer.
      def can_reorder_fields?
        test_capability('ReorderFields')
      end

      # @return [Boolean] +true+ if the Layer supports altering the defintition
      #   of an existing field on the current layer.
      def can_alter_field_definition?
        test_capability('AlterFieldDefn')
      end

      # @return [Boolean] +true+ if the Layer supports deleting Features.
      def can_delete_feature?
        test_capability('DeleteFeature')
      end

      # @return [Boolean] +true+ if :OFTString fields are guaranteed to be in
      #   UTF-8.
      def strings_are_utf_8?
        test_capability('StringsAsUTF8')
      end

      # @return [Boolean] +true+ if this Layer supports transactions. If not,
      #   #start_transaction, #commit_transaction, and #rollback_transaction
      #   will not work in a meaningful manner.
      def supports_transactions?
        test_capability('Transactions')
      end

      # @return [Boolean] +true+ if this Layer supports reading or writing
      #   curve geometries.
      def supports_curve_geometries?
        test_capability('CurveGeometries')
      end
    end
  end
end
