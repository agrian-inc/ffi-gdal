# typed: false
# frozen_string_literal: true

require 'ogr/layer'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

  describe '#name' do
    it 'returns the name given to it' do
      expect(subject.name).to eq 'spec layer'
    end
  end

  describe '#geometry_type' do
    it 'returns the type it was created with' do
      expect(subject.geometry_type).to eq :wkbMultiPoint
    end
  end

  describe '#sync_to_disk' do
    it 'does not die' do
      expect { subject.sync_to_disk }.to_not raise_exception
    end
  end

  describe '#test_capability' do
    context 'some supported capabilities to check' do
      let(:capabilities) do
        %w[OLCRandomRead OLCCreateField OLCCurveGeometries]
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

  describe '#spatial_reference' do
    context 'no spatial ref' do
      include_context 'OGR::Layer, no spatial_reference'

      it 'returns nil' do
        expect(subject.spatial_reference).to be_nil
      end
    end

    context 'with a spatial ref' do
      it 'returns an OGR::SpatialReference' do
        expect(subject.spatial_reference).to be_a OGR::SpatialReference
      end
    end
  end

  describe '#extent' do
    it 'returns an OGR::Envelope' do
      expect(subject.extent).to be_a OGR::Envelope
    end
  end

  describe '#extent_by_geometry' do
    context 'force is false' do
      it 'returns an OGR::Envelope' do
        expect(subject.extent_by_geometry(0, force: false)).to be_a OGR::Envelope
      end
    end

    context 'force is true' do
      it 'returns an OGR::Envelope' do
        expect(subject.extent_by_geometry(0, force: true)).to be_a OGR::Envelope
      end
    end
  end

  describe '#style_table= + #style_table' do
    context 'one is not set' do
      it 'returns nil' do
        expect(subject.style_table).to be_nil
      end
    end

    context 'one is set' do
      it 'returns an OGR::StyleTable' do
        subject.style_table = OGR::StyleTable.new
        expect(subject.style_table).to be_a OGR::StyleTable
      end
    end
  end
end
