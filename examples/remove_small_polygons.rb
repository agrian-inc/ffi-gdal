require 'bundler/setup'
require 'thor'
require 'fileutils'
require 'gdal/dataset'
require 'gdal/raster_band'

GDAL::Logger.logging_enabled = true

module Examples
  class RemoveSmallPolygons < ::Thor
    desc 'filter SOURCE_PATH DEST_PATH SIZE',
      'Removes polygons from SOURCE that are under SIZE'
    option :band_number, type: :numeric, default: 1
    def filter(source_path, dest_path, size)
      puts "Copying source '#{source_path}' to '#{dest_path}'..."
      FileUtils.cp(source_path, dest_path)

      size = size.to_f
      dataset = GDAL::Dataset.open(dest_path, 'w')
      puts "Raster area: #{dataset.extent.area}"
      raster_band = dataset.raster_band(options[:band_number])

      puts "Filtering polygons under size #{size}"
      raster_band.sieve_filter!(size, 4, progress_function: GDAL.simple_progress_formatter)
      shapefile_dir = "#{File.basename(dest_path, '.tif')}-shapefile"

      make_shapefile(shapefile_dir, dataset.spatial_reference.dup) do |layer|
        raster_band.polygonize(layer, pixel_value_field: 0)
      end

      puts "\nDone!"
    end

    private

    def make_shapefile(dir_path, srs)
      if File.exist?(dir_path)
        puts "Removing old shapefile: #{dir_path}"
        FileUtils.rm_rf(dir_path)
      end

      shp_driver = OGR::Driver.by_name 'ESRI Shapefile'
      data_source = shp_driver.create_data_source(dir_path)
      layer = data_source.create_layer('sieve-filtered', geometry_type: :wkbMultiPolygon,
                                                         spatial_reference: srs)
      zone_num_field_def = OGR::FieldDefinition.new 'ZONE', :OFTInteger
      layer.create_field(zone_num_field_def)
      yield layer

      puts "feature count: #{layer.feature_count}"

      layer.each_feature.with_index do |feature, i|
        area = feature.geometry.area
        puts "Feature #{i} area: #{area}"
        feature.destroy!
      end

      data_source.close
    end
  end
end

Examples::RemoveSmallPolygons.start(ARGV)
