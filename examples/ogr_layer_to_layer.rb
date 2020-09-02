# typed: strict
# frozen_string_literal: true

require 'bundler/setup'
require 'ffi-gdal'

include GDAL::Logger # rubocop:disable Style/MixinUsage
GDAL::Logger.logging_enabled = true

# http://pcjericks.github.io/py-gdalogr-cookbook/vector_layers.html#create-a-new-layer-from-the-extent-of-an-existing-layer

# Get a Layer's Extent
data_source = OGR::DataSource.open('../spec/support/shapefiles/states_21basic/states.shp', 'r')
layer = data_source.layer(0)
extent = layer.extent

# x_min = extent[:x_origin]
# x_max = extent[:x_max]
# y_min = extent[:y_origin]
# y_max = extent[:y_max]
# log "x_min: #{x_min}"
# log "y_min: #{y_min}"
# log "y_max: #{y_max}"
# log "x_max: #{x_max}"

# Create a polygon from the extent
ring = OGR::Geometry.create(:wkbLinearRing)
ring.add_point(extent.x_min, extent.y_min)
ring.add_point(extent.x_max, extent.y_min)
ring.add_point(extent.x_max, extent.y_max)
ring.add_point(extent.x_min, extent.y_max)
ring.add_point(extent.x_min, extent.y_min)
poly = OGR::Geometry.create(:wkbPolygon)
poly.add_geometry(ring)
