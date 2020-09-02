# typed: false
# frozen_string_literal: true

require 'gdal/driver'

RSpec.describe GDAL::Driver do
  describe '.count' do
    subject { described_class.count }
    it { is_expected.to be_positive }
  end

  describe '.by_name' do
    context 'not a driver' do
      it 'raises a GDAL::InvalidDriverName' do
        expect { described_class.by_name('blargh') }
          .to raise_exception GDAL::InvalidDriverName
      end
    end

    context 'valid driver name' do
      subject { described_class.by_name('MEM') }
      it { is_expected.to be_an_instance_of GDAL::Driver }
    end
  end

  describe '.at_index' do
    context 'invalid index' do
      it 'raises a GDAL::InvalidDriverIndex' do
        expect { described_class.at_index 123_456 }
          .to raise_exception GDAL::InvalidDriverIndex
      end
    end

    context 'valid index' do
      subject { described_class.at_index(0) }
      it { is_expected.to be_an_instance_of GDAL::Driver }
    end
  end

  describe '.identify_driver' do
    context 'file is not supported' do
      subject { described_class.identify_driver(__FILE__) }
      it { is_expected.to be_nil }
    end

    context 'file is supported' do
      subject { described_class.identify_driver('spec/support/worldfiles/SR_50M/SR_50M.tif') }
      it { is_expected.to be_an_instance_of GDAL::Driver }
    end
  end
end
