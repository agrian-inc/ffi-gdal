# typed: true
# frozen_string_literal: true

require_relative '../geometry_types/container'
require_relative '../geometry_types/surface'

module OGR
  class MultiPolygon
    include OGR::Geometry
    include GeometryTypes::Container
    include GeometryTypes::Surface

    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiPolygon)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end

    # @return [OGR::Geometry]
    def union_cascaded
      build_geometry { FFI::OGR::API.OGR_G_UnionCascaded(@c_pointer) }
    end
  end
end
