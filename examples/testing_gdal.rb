# typed: false
# frozen_string_literal: true

require 'RMagick'
require 'bundler/setup'
require 'ffi-gdal'

GDAL::Logger.logging_enabled = true

_floyd_too_big_wkt = 'MULTIPOLYGON (((-87.55634718933241 31.168633650404765,' \
'-87.552227316286 31.16870709121005, -87.55234533348232 31.169808696448463,' \
  '-87.5478606800096 31.1698913163249, -87.54777484932141 31.168679550914895,' \
  '-87.54380517997858 31.168615290194918, -87.54396611251944 31.16511760526154,' \
  '-87.55647593536513 31.164906454793982, -87.55634718933241 31.168633650404765)))'
floyd_wkt = 'MULTIPOLYGON (((-87.5530099868775 31.16710573359053,' \
'-87.5530099868775 31.165600160261103,-87.55384683609009 31.16710573359053,-87.5530099868775 31.16710573359053)))'
_floyd_srid = 4326

harper_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/Harper/Harper_1058_20140612_NRGB.tif'
_harper = GDAL::Dataset.open(harper_path, 'r')

floyd_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/Floyd/Floyd_1058_20140612_NRGB.tif'
floyd = GDAL::Dataset.open(floyd_path, 'r')

spatial_ref = OGR::SpatialReference.new(floyd.projection)
_floyd_geometry = OGR::Geometry.create_from_wkt(floyd_wkt, spatial_ref)

usg_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/osgeo/geotiff/usgs/c41078a1.tif'
_usg = GDAL::Dataset.open(usg_path, 'r')

world_file_path = "#{__dir__}/spec/support/worldfiles/SR_50M/SR_50M.tif"
_world_file = GDAL::GeoTransform.from_world_file(world_file_path, 'tfw')

# floyd.image_warp('meow.tif', 'GTiff', 1, cutline: floyd_geometry )
# extract_ndvi(floyd, 'ndvi.tif', floyd_wkt)

def warp_to_geometry(dataset, wkt_geometry)
  # Create an OGR::Geometry from the WKT and convert to dataset's projection.
  wkt_spatial_ref = OGR::SpatialReference.new_from_epsg(4326)
  geometry = OGR::Geometry.create_from_wkt(wkt_geometry, wkt_spatial_ref)
  geometry.transform_to!(dataset.spatial_reference)

  # Create a .shp from the geometry
  shape = geometry.to_vector('geom.shp', 'ESRI Shapefile',
                             spatial_reference: dataset.spatial_reference)
  shape.close
end

# warp_to_geometry(floyd, floyd_wkt)
