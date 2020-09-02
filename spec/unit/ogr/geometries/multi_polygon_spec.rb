# typed: false
# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiPolygon do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end

  it_behaves_like 'a container geometry' do
    let(:child_geometry) { OGR::Polygon.new }
  end

  describe '#to_polygon' do
    subject { OGR::Geometry.create_from_wkt(wkt) }

    let(:wkt) do
      'MULTIPOLYGON(((0 0,0 1,1 1,0 0)),((0 0,1 1,1 0,0 0)))'
    end

    it 'returns a Polygon' do
      expect(subject.to_polygon).to be_a OGR::Polygon
    end
  end

  describe '#union_cascaded' do
    subject { OGR::Geometry.create_from_wkt(wkt) }

    let(:wkt) do
      'MULTIPOLYGON(((0 0,0 1,1 1,0 0)),((0 0,1 1,1 0,0 0)))'
    end

    it 'returns a Geometry' do
      expect(subject.union_cascaded).to be_a OGR::Polygon
    end

    it 'does a union on the geometry' do
      expect(subject.union_cascaded.to_wkt)
        .to eq 'POLYGON ((0 0,0 1,1 1,1 0,0 0))'
    end
  end
end
