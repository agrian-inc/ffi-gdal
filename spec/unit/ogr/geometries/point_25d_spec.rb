# typed: false
# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::Point25D do
  describe '#type' do
    context 'when created with data' do
      subject { OGR::Geometry.create_from_wkt(wkt) }
      let(:wkt) { 'POINT(1 2 3)' }

      it 'returns :wkbPoint25D' do
        expect(subject.type).to eq :wkbPoint25D
      end
    end

    context 'when created without data' do
      subject { described_class.new }

      it 'returns :wkbPoint' do
        expect(subject.type).to eq :wkbPoint
      end
    end
  end
end
