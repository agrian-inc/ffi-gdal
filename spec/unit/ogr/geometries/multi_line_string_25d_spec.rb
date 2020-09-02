# typed: false
# frozen_string_literal: true

require 'ogr'

RSpec.describe OGR::MultiLineString25D do
  describe '#type' do
    context 'when created with data' do
      subject { OGR::Geometry.create_from_wkt(wkt) }
      let(:wkt) { 'MULTILINESTRING((1 2 3, 2 2 3),(9 9 9, 10 10 10))' }

      it 'returns :wkbMultiLineString25D' do
        expect(subject.type).to eq :wkbMultiLineString25D
      end
    end

    context 'when created without data' do
      subject { described_class.new }

      it 'returns :wkbMultiLineString' do
        expect(subject.type).to eq :wkbMultiLineString
      end
    end
  end
end
