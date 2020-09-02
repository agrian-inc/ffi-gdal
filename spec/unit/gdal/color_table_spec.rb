# typed: false
# frozen_string_literal: true

require 'gdal/color_table'

RSpec.describe GDAL::ColorTable do
  describe '#initialize' do
    context 'with a valid PaletteInterpretation' do
      it 'creates a new ColorTable' do
        expect(described_class.new(:GPI_RGB)).to be_a(described_class)
      end
    end

    context 'with an invalid PaletteInterpretation' do
      it 'raises an GDAL::InvalidColorTable' do
        expect do
          described_class.new(:MEOW)
        end.to raise_exception(GDAL::InvalidColorTable)
      end
    end

    context ':GPI_RGB' do
      it 'extends the new object with the ColorTableTypes::RGB module' do
        expect_any_instance_of(described_class).to receive(:extend)
          .with(GDAL::ColorTableTypes::RGB)
        described_class.new(:GPI_RGB)
      end
    end

    context ':GPI_Gray' do
      it 'extends the new object with the ColorTableTypes::Gray module' do
        expect_any_instance_of(described_class).to receive(:extend)
          .with(GDAL::ColorTableTypes::Gray)
        described_class.new(:GPI_Gray)
      end
    end

    context ':GPI_CMYK' do
      it 'extends the new object with the ColorTableTypes::CMYK module' do
        expect_any_instance_of(described_class).to receive(:extend)
          .with(GDAL::ColorTableTypes::CMYK)
        described_class.new(:GPI_CMYK)
      end
    end

    context ':GPI_HLS' do
      it 'extends the new object with the ColorTableTypes::HLS module' do
        expect_any_instance_of(described_class).to receive(:extend)
          .with(GDAL::ColorTableTypes::HLS)
        described_class.new(:GPI_HLS)
      end
    end
  end

  subject do
    described_class.new(:GPI_RGB)
  end

  describe '#palette_interpretation' do
    it 'equals the symbol that was given during .create' do
      expect(subject.palette_interpretation).to eq :GPI_RGB
    end
  end

  describe '#color_entry_count' do
    it 'defaults to 0' do
      expect(subject.color_entry_count).to be_zero
    end
  end

  describe '#color_entry' do
    context 'when no entries' do
      it 'returns nil' do
        expect(subject.color_entry(900)).to be_nil
      end
    end

    context 'when entries' do
      before do
        subject.add_color_entry(0)
      end

      it 'returns the ColorEntry' do
        expect(subject.color_entry(0)).to be_a GDAL::ColorEntry
      end
    end
  end

  describe '#color_entry_as_rgb' do
    context 'when no entries' do
      it 'returns nil' do
        expect(subject.color_entry_as_rgb(900)).to be_nil
      end
    end

    context 'when entries' do
      before do
        subject.add_color_entry(0)
      end

      it 'returns the ColorEntry' do
        expect(subject.color_entry_as_rgb(0)).to be_a GDAL::ColorEntry
      end
    end
  end

  describe '#add_color_entry' do
    context 'no values given' do
      it 'creates and returns the entry' do
        expect(subject.add_color_entry(0)).to be_a GDAL::ColorEntry
      end
    end

    context 'all values given' do
      it 'creates and returns the entry' do
        expect(subject.add_color_entry(0, 75, 250, 255)).to be_a GDAL::ColorEntry
      end
    end

    context 'bad values given' do
      it 'creates and returns the entry' do
        expect(subject.add_color_entry(0, 300, 250, 255)).to be_a GDAL::ColorEntry
      end
    end
  end

  describe '#create_color_ramp!' do
    context 'no color entries' do
      it 'returns nil' do
        entry0 = GDAL::ColorEntry.new
        entry1 = GDAL::ColorEntry.new
        expect(subject.create_color_ramp!(0, entry0, 1, entry1)).to be_nil
      end
    end

    context 'color entries that exist' do
      it 'returns nil' do
        entry0 = subject.add_color_entry(0, 0, 0, 0, 0)
        _entry1 = subject.add_color_entry(1, 10, 10, 10, 10)
        entry2 = subject.add_color_entry(2, 100, 100, 100, 100)

        expect(subject.create_color_ramp!(0, entry0, 2, entry2)).to be_nil
      end
    end
  end
end
