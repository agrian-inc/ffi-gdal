# typed: true
# frozen_string_literal: true

require_relative 'line_string'

module OGR
  # NOTE: {{#type}} will return :wkbLineString (read: 2D instead of 2.5D) until
  # a Z value is set.
  class LineString25D < LineString
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbLineString25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end
  end
end
