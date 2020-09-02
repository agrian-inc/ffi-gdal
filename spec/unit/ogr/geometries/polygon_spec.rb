# typed: false
# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::Polygon do
  subject(:polygon) { OGR::Geometry.create_from_wkt(wkt) }
  let(:wkt) { 'POLYGON((10 10, 20 20, 30 30))' }

  it_behaves_like 'a geometry' do
    let(:geometry) { polygon }
  end

  describe '#to_multi_polygon' do
    it 'returns a MultiPolygon' do
      expect(subject.to_multi_polygon).to be_a OGR::MultiPolygon
    end
  end
end
