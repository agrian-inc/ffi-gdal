# typed: false
# frozen_string_literal: true

require 'gdal/options'

RSpec.describe GDAL::Options do
  describe '.to_hash' do
    subject { described_class.to_hash(pointer) }

    context 'options are set' do
      let(:pointer) { described_class.pointer(hash) }

      let(:hash) do
        {
          one: 'ONE',
          two: 'TWO'
        }
      end

      it 'returns the Ruby Hash' do
        expect(subject).to eq(hash)
      end
    end

    context 'pointer is null' do
      let(:pointer) { FFI::MemoryPointer.new(:string) }

      it 'returns an empty Hash' do
        expect(subject).to eq({})
      end
    end
  end
end
