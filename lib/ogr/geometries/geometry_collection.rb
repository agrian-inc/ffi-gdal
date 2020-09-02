# typed: true
# frozen_string_literal: true

require_relative '../geometry_types/container'
require_relative '../geometry_types/surface'

module OGR
  class GeometryCollection
    include OGR::Geometry
    include GeometryTypes::Container
    include GeometryTypes::Surface

    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbGeometryCollection)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end
  end
end
