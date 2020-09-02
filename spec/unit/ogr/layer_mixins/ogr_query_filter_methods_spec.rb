# typed: false
# frozen_string_literal: true

require 'ogr/layer'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

  describe '#spatial_filter' do
    context 'default' do
      subject { layer.spatial_filter }
      it { is_expected.to be_nil }
    end
  end

  describe '#spatial_filter= + #spatial_filter' do
    it 'assigns the spatial_filter to the new geometry' do
      geometry = OGR::Geometry.create_from_wkt('POINT (1 1)')
      subject.spatial_filter = geometry
      expect(subject.spatial_filter).to eq geometry
    end
  end

  describe '#set_spatial_filter_ex' do
    it 'does not die' do
      geometry = OGR::Geometry.create_from_wkt('POINT (1 1)')
      expect { subject.set_spatial_filter_ex(0, geometry) }.to_not raise_exception
    end
  end

  describe '#set_spatial_filter_rectangle' do
    it 'does not die' do
      expect { subject.set_spatial_filter_rectangle(0, 0, 1000, 1000) }
        .to_not raise_exception
    end
  end

  describe '#set_spatial_filter_rectangle_ex' do
    it 'does not die' do
      expect { subject.set_spatial_filter_rectangle_ex(0, 0, 0, 1000, 1000) }
        .to_not raise_exception
    end
  end
end
