# typed: false
# frozen_string_literal: true

require 'ogr/driver'

RSpec.describe OGR::Driver do
  describe '.count' do
    subject { described_class.count }
    it { is_expected.to be_a Integer }
  end

  describe '.by_name' do
    it 'can return an OGR::Driver' do
      expect(described_class.by_name('Memory')).to be_a OGR::Driver
    end
  end

  describe '.at_index' do
    context 'valid index' do
      it 'returns an OGR::Driver' do
        expect(described_class.at_index(0)).to be_a OGR::Driver
      end
    end

    context 'invalid index' do
      it 'raises an OGR::DriverNotFound' do
        expect { described_class.at_index(123_456) }
          .to raise_exception OGR::DriverNotFound
      end
    end
  end

  describe '.names' do
    it 'returns an Array of Strings' do
      expect(described_class.names).to be_an Array
      expect(described_class.names.first).to be_a String
    end
  end

  subject(:memory_driver) { described_class.by_name('Memory') }
  let(:shapefile_driver) { described_class.by_name('ESRI Shapefile') }

  describe '#name' do
    subject { memory_driver.name }
    it { is_expected.to eq 'Memory' }
  end

  describe '#open' do
    context 'data source at path does not exist' do
      context 'with write flag' do
        it 'raises an OGR::InvalidDataSource' do
          expect { subject.open('spec source', 'w') }
            .to raise_exception OGR::InvalidDataSource
        end
      end

      context 'with read flag' do
        it 'raises an OGR::InvalidDataSource' do
          expect { subject.open('spec source', 'r') }
            .to raise_exception OGR::InvalidDataSource
        end
      end
    end

    context 'data source at path exists' do
      let(:shapefile_path) do
        'spec/support/shapefiles/states_21basic/states.shp'
      end

      context 'with write flag' do
        it 'returns an OGR::DataSource' do
          data_source = shapefile_driver.open(shapefile_path, 'w')
          expect(data_source).to be_a OGR::DataSource
        end
      end

      context 'with read flag' do
        it 'returns an OGR::DataSource' do
          data_source = shapefile_driver.open(shapefile_path, 'r')
          expect(data_source).to be_a OGR::DataSource
        end
      end

      context 'using a driver that does not support the file type' do
        it 'raises an OGR::InvalidDataSource' do
          expect { memory_driver.open(shapefile_path, 'r') }
            .to raise_exception OGR::InvalidDataSource
        end
      end
    end
  end

  describe '#create_data_source' do
    context 'creation not supported' do
      before do
        expect(subject).to receive(:can_create_data_source?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.create_data_source('test') }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'creation supported' do
      context 'block given' do
        it 'yields the new DataSource to the block' do
          expect do |b|
            subject.create_data_source('test source', &b)
          end.to yield_with_args OGR::DataSource
        end
      end

      context 'no block given' do
        it 'returns the new data source' do
          expect(subject.create_data_source('test source'))
            .to be_a OGR::DataSource
        end
      end
    end
  end

  describe '#delete_data_source' do
    context 'does not support deleting' do
      context 'data source does not exist' do
        it "raises a OGR::UnsupportedOperation (Memory driver doesn't support)" do
          expect { subject.delete_data_source('we no here') }.to raise_exception OGR::UnsupportedOperation
        end
      end
    end
  end

  describe '#copy_data_source' do
    context 'source data source does not exist' do
      it 'raises an OGR::InvalidDataSource' do
        expect do
          subject.copy_data_source('not a pointer', 'bobo')
        end.to raise_exception OGR::InvalidDataSource
      end
    end

    context 'source data source exists' do
      let(:data_source) do
        subject.create_data_source('datasource1')
      end

      it 'returns the new OGR::DataSource' do
        expect(subject.copy_data_source(data_source, 'datasource2'))
          .to be_a OGR::DataSource
      end
    end
  end
end
