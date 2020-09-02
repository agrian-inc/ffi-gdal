# typed: false
# frozen_string_literal: true

require 'gdal/virtual_dataset'
require 'gdal/dataset'

RSpec.describe GDAL::VirtualDataset do
  subject(:virtual_dataset) { described_class.new(300, 200) }

  describe '#initialize' do
    it { is_expected.to be_a GDAL::VirtualDataset }
  end

  describe '#flush_cache' do
    it 'does something' do
      subject.flush_cache
    end
  end

  describe '#to_xml' do
    it 'returns a String' do
      expect(subject.to_xml).to be_a String
      expect(subject.to_xml.size).to be_positive
    end
  end

  describe '#add_band' do
    context 'valid data type' do
      it "lets you add a real dataset's raster band to it" do
        expect(subject.add_band(:GDT_Byte)).to eq 0
      end
    end
  end
end
