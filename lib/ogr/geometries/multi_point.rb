# typed: true
# frozen_string_literal: true

require_relative '../geometry_types/container'

module OGR
  class MultiPoint
    include OGR::Geometry
    include GeometryTypes::Container

    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiPoint)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end
  end
end
