# typed: false
# frozen_string_literal: true

module OGR
  module DataSourceMixins
    # Helper methods for determining the current DataSource's capabilities.
    module CapabilityMethods
      # @return [Boolean] +true+ if the DataSource can create existing Layers.
      def can_create_layer?
        test_capability('CreateLayer')
      end

      # @return [Boolean] +true+ if the DataSource can delete existing Layers.
      def can_delete_layer?
        test_capability('DeleteLayer')
      end

      # @return [Boolean] +true+ if the DataSource supports creating a
      #   GeometryField after a Layer has been created.
      def can_create_geometry_field_after_create_layer?
        test_capability('CreateGeomFieldAfterCreateLayer')
      end

      # @return [Boolean] +true+ if the DataSource supports curve geometries.
      def supports_curve_geometries?
        test_capability('CurveGeometries')
      end
    end
  end
end
