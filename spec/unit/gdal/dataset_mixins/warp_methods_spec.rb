# typed: false
# frozen_string_literal: true

require 'gdal'

RSpec.describe GDAL::Dataset do
  let(:source_file_path) do
    File.expand_path('../../../support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif', __dir__)
  end

  let(:output_dir) { Dir.mktmpdir(File.basename(__FILE__, '.rb')) }
  let(:output_file) { File.join(output_dir, 'reprojected_image.tif') }

  after { FileUtils.rm_rf(output_dir) if Dir.exist?(output_dir) }

  subject { described_class.open(source_file_path, 'r', shared: false) }

  describe '#reproject_image' do
    let(:dest_dataset) do
      dest_width = subject.raster_x_size / 4
      dest_height = subject.raster_y_size / 4
      dataset = GDAL::Driver.by_name('GTiff').create_dataset(output_file, dest_width, dest_height,
                                                             data_type: subject.raster_band(1).data_type)
      dataset.geo_transform = subject.geo_transform.dup
      dataset.projection = OGR::SpatialReference.new_from_epsg(3857).to_wkt
      dataset
    end

    after { dest_dataset.close }

    it 'creates a valid dataset' do
      subject.reproject_image(dest_dataset, :GRA_CubicSpline)

      dest_dataset.flush_cache
      expect(dest_dataset.projection).to match(/AUTHORITY\["EPSG","3857"\]/)
      expect(dest_dataset.raster_count).to eq(subject.raster_count)
    end
  end

  describe '#create_and_reproject_image' do
    let(:output_projection) { OGR::SpatialReference.new_from_epsg(3857).to_wkt }

    it 'creates a valid dataset' do
      subject.create_and_reproject_image(output_file, :GRA_NearestNeighbor,
                                         OGR::SpatialReference.new_from_epsg(3857).to_wkt,
                                         GDAL::Driver.by_name('GTiff'))

      dest_dataset = GDAL::Dataset.open(output_file, 'r')
      expect(dest_dataset.projection).to match(/AUTHORITY\["EPSG","3857"\]/)
      expect(dest_dataset.raster_count).to eq(subject.raster_count)

      dest_driver = dest_dataset.driver
      expect(dest_driver.long_name).to eq 'GeoTIFF'
    end
  end
end
