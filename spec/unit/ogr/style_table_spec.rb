# typed: false
# frozen_string_literal: true

require 'ogr/style_table'

RSpec.describe OGR::StyleTable do
  describe '#add_style + #find' do
    it '#add_style returns true' do
      expect(subject.add_style('test style', '#ffffff')).to eq true
    end
  end

  describe '#add_style + #find' do
    it 'adds the style to the table' do
      subject.add_style('test style', '#ffffff')
      expect(subject.find('test style')).to eq '#ffffff'
    end
  end

  describe '#next_style + #last_style_name' do
    context 'without styles' do
      context 'after calling #next_style' do
        it '#last_style_name returns an empty string' do
          subject.next_style
          expect(subject.last_style_name).to be_empty
        end
      end
    end

    context 'with styles' do
      subject do
        st = described_class.new
        st.add_style('test style', '12345')
        st
      end

      context 'without calling #next_style' do
        it '#last_style_name returns an empty string' do
          expect(subject.last_style_name).to be_empty
        end
      end

      context 'after calling #next_style' do
        it '#last_style_name returns the name of the last style' do
          subject.next_style
          expect(subject.last_style_name).to eq 'test style'
        end
      end
    end
  end

  describe '#load!' do
    context 'file exists' do
      let(:file_path) do
        'spec/support/test_style_table.txt'
      end

      it 'returns true and imports the styles from the file' do
        expect(subject.load!(file_path)).to eq true
        expect(subject.find('meow things')).to eq 'Meow'
      end
    end

    context 'file does not exist' do
      it 'raises a GDAL::OpenFailure' do
        expect do
          subject.load!('blargh')
        end.to raise_exception GDAL::OpenFailure
      end
    end
  end

  describe '#reset_style_string_reading' do
    subject do
      st = described_class.new
      st.add_style('style1', '12345')
      st.add_style('style2', '67890')
      st
    end

    it 'returns the #next_style back to the first style' do
      subject.next_style
      subject.next_style
      subject.reset_style_string_reading
      expect(subject.next_style).to eq '12345'
    end
  end
end
