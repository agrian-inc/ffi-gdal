# typed: true
# frozen_string_literal: true

require_relative '../geometry_types/curve'
require_relative '../geometry_types/container'

module OGR
  class MultiLineString
    include OGR::Geometry
    include GeometryTypes::Curve
    include GeometryTypes::Container

    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiLineString)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end
  end
end
