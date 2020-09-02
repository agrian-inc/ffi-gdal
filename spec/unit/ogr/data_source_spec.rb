# typed: false
# frozen_string_literal: true

require 'ogr/data_source'
require 'ogr/spatial_reference'

RSpec.describe OGR::DataSource do
  describe '.open' do
    context 'not a data source' do
      it 'raises an OGR::OpenFailure' do
        expect do
          described_class.open('blarg', 'r')
        end.to raise_exception OGR::OpenFailure
      end
    end

    context 'block given' do
      let(:data_source) { instance_double 'OGR::DataSource' }

      it 'yields then closes the opened DataSource' do
        allow(described_class).to receive(:new).and_return data_source

        expect(data_source).to receive(:close)
        expect { |b| described_class.open('blarg', 'r', &b) }
          .to yield_with_args(data_source)
      end
    end
  end

  let(:driver) { OGR::Driver.by_name 'Memory' }

  subject(:data_source) do
    driver.create_data_source('spec')
  end

  describe '#name' do
    subject { data_source.name }
    it { is_expected.to eq 'spec' }
  end

  describe '#driver' do
    subject { data_source.driver.name }
    it { is_expected.to eq 'Memory' }
  end

  describe '#layer_count' do
    subject { data_source.layer_count }
    it { is_expected.to be_zero }
  end

  describe '#layer' do
    context 'no layers' do
      subject { data_source.layer(0) }
      it { is_expected.to be_nil }
    end

    context '1 layer' do
      before { data_source.create_layer 'unknown layer' }
      subject { data_source.layer(0) }
      it { is_expected.to be_a OGR::Layer }
    end
  end

  describe '#layer_by_name' do
    context 'no layers' do
      subject { data_source.layer_by_name 'meow' }
      it { is_expected.to be_nil }
    end

    context '1 layer' do
      before { data_source.create_layer 'unknown layer' }
      subject { data_source.layer_by_name 'unknown layer' }
      it { is_expected.to be_a OGR::Layer }
    end
  end

  describe '#create_layer' do
    context 'cannot create layer' do
      before do
        expect(subject).to receive(:can_create_layer?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.create_layer('test') }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'can create layer' do
      context 'geometry type is :wkbUnknown' do
        it 'adds a new OGR::Layer to @layers' do
          expect do
            data_source.create_layer('unknown layer')
          end.to change { data_source.layer_count }.by 1
        end

        it 'has a layer that is the given geometry type' do
          layer = data_source.create_layer('unknown layer', geometry_type: :wkbUnknown)
          expect(layer.geometry_type).to eq :wkbUnknown
        end
      end

      context 'geometry type is *not* :wkbUnknown' do
        it 'adds a new OGR::Layer to @layers' do
          expect do
            data_source.create_layer('polygon layer', geometry_type: :wkbPolygon)
          end.to change { data_source.layer_count }.by 1
        end

        it 'has a layer that is the given geometry type' do
          layer = data_source.create_layer('polygon layer', geometry_type: :wkbPolygon)
          expect(layer.geometry_type).to eq :wkbPolygon
        end
      end

      context 'spatial reference is passed in' do
        let(:spatial_reference) { OGR::SpatialReference.new_from_epsg(4326) }

        it 'adds a new OGR::Layer to @layers' do
          expect do
            data_source.create_layer('polygon layer', spatial_reference: spatial_reference)
          end.to change { data_source.layer_count }.by 1
        end

        it 'has a layer that uses that spatial reference' do
          layer = data_source.create_layer('polygon layer', spatial_reference: spatial_reference)
          expect(layer.spatial_reference.to_wkt).to eq spatial_reference.to_wkt
        end
      end
    end
  end

  describe '#copy_layer' do
    let!(:unknown_layer) { subject.create_layer 'unknown layer' }

    it 'adds a new OGR::Layer to @layers' do
      expect do
        subject.copy_layer(unknown_layer, 'meow layer')
      end.to change { subject.layer_count }.by 1
    end

    it 'makes a copy of the layer' do
      copied_layer = subject.copy_layer(unknown_layer, 'meow layer')
      expect(copied_layer.geometry_type).to eq unknown_layer.geometry_type
    end
  end

  describe '#delete_layer' do
    context 'deleting not supported' do
      before do
        expect(subject).to receive(:can_delete_layer?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.delete_layer(0) }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'deleting is supported' do
      context 'no layers' do
        it 'raises a OGR::Failure' do
          expect do
            data_source.delete_layer(0)
          end.to raise_exception OGR::Failure
        end
      end

      context '1 layer' do
        before { data_source.create_layer 'unknown layer' }
        subject { data_source.delete_layer(0) }
        it { is_expected.to eq nil }
      end
    end
  end

  describe '#style_table' do
    context 'no associated style table' do
      subject { data_source.style_table }
      it { is_expected.to be_nil }
    end
  end

  describe '#style_table=' do
    context 'no style table associated' do
      let(:style_table) do
        st = OGR::StyleTable.new
        st.add_style('test', '#123456')
        st
      end

      it 'assigns the new style table' do
        subject.style_table = style_table
        expect(subject.style_table.find('test')).to eq '#123456'
      end
    end
  end

  describe '#test_capability' do
    context 'supported capabilities to check' do
      let(:capabilities) do
        %w[ODsCCreateLayer ODsCDeleteLayer ODsCCreateGeomFieldAfterCreateLayer ODsCCurveGeometries]
      end

      # I don't get why these return false...
      it 'returns false' do
        capabilities.each do |capability|
          expect(subject.test_capability(capability)).to eq false
        end
      end
    end

    context 'unsupported capabilities to check' do
      it 'returns false' do
        expect(subject.test_capability('meow')).to eq false
      end
    end
  end

  describe '#sync_to_disk' do
    it do
      expect(subject.sync_to_disk).to be_nil
    end
  end
end
