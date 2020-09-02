# typed: true
# frozen_string_literal: true

require_relative 'polygon'

module OGR
  # NOTE: {{#type}} will return :wkbPolygon (read: 2D instead of 2.5D) until a Z
  # value is set.
  class Polygon25D < Polygon
    # @param geometry_ptr [FFI::Pointer]
    # @param spatial_reference [OGR::SpatialReference]
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbPolygon25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end
  end
end
