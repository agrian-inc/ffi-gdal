# typed: false
# frozen_string_literal: true

require 'gdal/color_interpretation'

RSpec.describe GDAL::ColorInterpretation do
  describe '.name' do
    context 'valid value' do
      it 'returns an object' do
        expect(GDAL::ColorInterpretation.name(:GCI_BlueBand)).to eq 'Blue'
      end
    end
  end

  describe '.by_name' do
    context 'valid name' do
      it 'returns an object' do
        expect(GDAL::ColorInterpretation.by_name('Blue')).to eq :GCI_BlueBand
      end
    end
  end
end
