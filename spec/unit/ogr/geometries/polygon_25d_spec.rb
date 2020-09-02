# typed: false
# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::Polygon25D do
  describe '#type' do
    context 'when created with data' do
      subject { OGR::Geometry.create_from_wkt(wkt) }
      let(:wkt) { 'POLYGON((0 0 1,0 1 1,1 1 1,0 0 1))' }

      it 'returns :wkbPolygon25D' do
        expect(subject.type).to eq :wkbPolygon25D
      end
    end

    context 'when created without data' do
      subject { described_class.new }

      it 'returns :wkbPolygon' do
        expect(subject.type).to eq :wkbPolygon
      end
    end
  end
end
