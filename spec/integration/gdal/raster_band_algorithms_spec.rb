# typed: false
# frozen_string_literal: true

require 'gdal/dataset'
require 'gdal/raster_band'

RSpec.describe GDAL::RasterBand, type: :integration do
  describe '#sieve_filter!' do
    let(:source_image_path) { 'spec/support/images/osgeo/geotiff/zi_imaging/image0.tif' }
    let(:dest_image_path) { 'tmp/image0.tif' }

    before do
      FileUtils.rm(dest_image_path) if File.exist?(dest_image_path)
      FileUtils.cp(source_image_path, dest_image_path)
    end

    it 'removes some polygons' do
      dataset = GDAL::Dataset.open(dest_image_path, 'w')
      band = dataset.raster_band(1)

      ogr_driver = OGR::Driver.by_name('Memory')
      data_source = ogr_driver.create_data_source('meow')
      layer_before = data_source.create_layer('before', spatial_reference: dataset.spatial_reference)
      band.polygonize(layer_before)

      band.sieve_filter!(1000, 4)
      layer_after = data_source.create_layer('after', spatial_reference: dataset.spatial_reference)
      band.polygonize(layer_after)

      expect(layer_before.feature_count).to eq 62
      expect(layer_after.feature_count).to eq 15
      dataset.close
    end
  end
end
