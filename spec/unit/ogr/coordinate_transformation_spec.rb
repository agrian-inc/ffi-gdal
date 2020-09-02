# typed: false
# frozen_string_literal: true

require 'ogr/coordinate_transformation'

RSpec.describe OGR::CoordinateTransformation do
  let(:source_srs) { OGR::SpatialReference.new_from_epsg(3857) }
  let(:dest_srs) { OGR::SpatialReference.new_from_epsg(4326) }

  # From https://epsg.io/3857
  let(:epsg4326_y_bounds) { [-85.06, 85.06] }
  let(:epsg4326_x_bounds) { [-180.0, 180.0] }
  let(:epsg3857_y_bounds) { [-20_048_966.10, 20_048_966.10] }
  let(:epsg3857_x_bounds) { [-20_026_376.39, 20_026_376.39] }

  subject { described_class.new(source_srs, dest_srs) }

  describe '.proj4_normalize' do
    context 'OCTProj4Normalize not supported' do
      it 'raises a OGR::UnsupportedOperation' do
        expect { described_class.proj4_normalize('asdf') }.to raise_exception(OGR::UnsupportedOperation)
      end
    end
  end

  describe '#initialize' do
    context 'source_srs is not an OGR::SpatialReference' do
      it do
        expect { described_class.new(123, dest_srs) }
          .to raise_exception GDAL::Error
      end
    end

    context 'dest_srs is not an OGR::SpatialReference' do
      it do
        expect { described_class.new(source_srs, 123) }
          .to raise_exception GDAL::Error
      end
    end

    context 'source_srs and dest_srs are valid OGR::SpatialReference objects' do
      it 'creates a new object with @c_pointer set' do
        instance = described_class.new(source_srs, dest_srs)
        expect(instance).to be_a described_class
        expect(instance.c_pointer).to be_a FFI::Pointer
      end
    end
  end

  describe '#transform' do
    context 'no z_vertices, valid x and y vertices' do
      it 'transforms the points' do
        result = subject.transform(epsg3857_x_bounds, epsg3857_y_bounds)

        transformed_x_points = result.first
        transformed_y_points = result.last

        expect(transformed_x_points.first).to be_within(0.11).of(epsg4326_x_bounds.first)
        expect(transformed_x_points.last).to be_within(0.11).of(epsg4326_x_bounds.last)
        expect(transformed_y_points.first).to be_within(0.001).of(epsg4326_y_bounds.first)
        expect(transformed_y_points.last).to be_within(0.001).of(epsg4326_y_bounds.last)
      end
    end

    context 'valid x, y, and z vertices' do
      it 'transforms the points' do
        result = subject.transform(epsg3857_x_bounds, epsg3857_y_bounds, [10_000, -299])

        transformed_x_points = result.first
        transformed_y_points = result[1]
        transformed_z_points = result.last

        expect(transformed_x_points.first).to be_within(0.11).of(epsg4326_x_bounds.first)
        expect(transformed_x_points.last).to be_within(0.11).of(epsg4326_x_bounds.last)
        expect(transformed_y_points.first).to be_within(0.001).of(epsg4326_y_bounds.first)
        expect(transformed_y_points.last).to be_within(0.001).of(epsg4326_y_bounds.last)
        expect(transformed_z_points.first).to eq(10_000)
        expect(transformed_z_points.last).to eq(-299)
      end
    end
  end

  describe '#transform_ex' do
    context 'no z_vertices, valid x and y vertices' do
      it 'transforms the points' do
        result = subject.transform_ex(epsg3857_x_bounds, epsg3857_y_bounds)

        transformed_x_points = result[:points].first
        transformed_y_points = result[:points].last

        expect(transformed_x_points.first).to be_within(0.11).of(epsg4326_x_bounds.first)
        expect(transformed_x_points.last).to be_within(0.11).of(epsg4326_x_bounds.last)
        expect(transformed_y_points.first).to be_within(0.001).of(epsg4326_y_bounds.first)
        expect(transformed_y_points.last).to be_within(0.001).of(epsg4326_y_bounds.last)
        expect(result[:successes]).to eq([true, false])
      end
    end
  end
end
