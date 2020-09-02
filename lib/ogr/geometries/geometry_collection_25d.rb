# typed: true
# frozen_string_literal: true

require_relative 'geometry_collection'

module OGR
  # NOTE: {{#type}} will return :wkbGeometryCollection (read: 2D instead of
  # 2.5D) until a Z value is set.
  class GeometryCollection25D < GeometryCollection
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbGeometryCollection25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end
  end
end
