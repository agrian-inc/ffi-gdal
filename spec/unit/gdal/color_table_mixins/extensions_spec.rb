# typed: false
# frozen_string_literal: true

require 'gdal/color_table'

RSpec.describe GDAL::ColorTable do
  subject do
    described_class.new(:GPI_RGB)
  end

  describe '#color_entries_for' do
    context 'no colors' do
      it 'returns an empty array' do
        expect(subject.color_entries_for(1)).to be_empty
      end
    end

    context 'colors' do
      it 'returns all of the color values ColorEntrys for the color number' do
        subject.add_color_entry(0, 1, 2, 3, 4)
        subject.add_color_entry(1, 10, 20, 30, 40)
        expect(subject.color_entries_for(1)).to eq([1, 10])
      end
    end
  end

  describe '#color_entries' do
    context 'no colors' do
      it 'returns an empty array' do
        expect(subject.color_entries).to be_empty
      end
    end

    context 'colors' do
      it 'returns an array of the ColorEntrys' do
        subject.add_color_entry(0, 1, 2, 3, 4)
        subject.add_color_entry(1, 10, 20, 30, 40)

        expect(subject.color_entries.size).to eq 2
        expect(subject.color_entries.first).to be_a GDAL::ColorEntry
      end
    end
  end

  describe '#color_entries_as_rgb' do
    context 'no colors' do
      it 'returns an empty array' do
        expect(subject.color_entries_as_rgb).to be_empty
      end
    end

    context 'colors' do
      it 'returns an array of the ColorEntrys' do
        subject.add_color_entry(0, 1, 2, 3, 4)
        subject.add_color_entry(1, 10, 20, 30, 40)

        expect(subject.color_entries_as_rgb.size).to eq 2
        expect(subject.color_entries_as_rgb.first).to be_a GDAL::ColorEntry
      end
    end
  end
end
