# typed: false
# frozen_string_literal: true

require 'ogr/layer'

RSpec.describe OGR::Layer do
  context 'Memory driver' do
    include_context 'OGR::Layer, no spatial_reference'

    describe '#can_random_read?' do
      subject { layer.can_random_read? }
      it { is_expected.to eq true }
    end

    describe '#can_sequential_write?' do
      subject { layer.can_sequential_write? }
      it { is_expected.to eq true }
    end

    describe '#can_random_write?' do
      subject { layer.can_random_write? }
      it { is_expected.to eq true }
    end

    describe '#can_fast_spatial_filter?' do
      subject { layer.can_fast_spatial_filter? }
      it { is_expected.to eq false }
    end

    describe '#can_fast_feature_count?' do
      subject { layer.can_fast_feature_count? }
      it { is_expected.to eq true }
    end

    describe '#can_fast_get_extent?' do
      subject { layer.can_fast_get_extent? }
      it { is_expected.to eq false }
    end

    describe '#can_fast_set_next_by_index?' do
      subject { layer.can_fast_set_next_by_index? }
      it { is_expected.to eq true }
    end

    describe '#can_create_field?' do
      subject { layer.can_create_field? }
      it { is_expected.to eq true }
    end

    describe '#can_create_geometry_field?' do
      subject { layer.can_create_geometry_field? }
      it { is_expected.to eq true }
    end

    describe '#can_delete_field?' do
      subject { layer.can_delete_field? }
      it { is_expected.to eq true }
    end

    describe '#can_reorder_fields?' do
      subject { layer.can_reorder_fields? }
      it { is_expected.to eq true }
    end

    describe '#can_alter_field_definition?' do
      subject { layer.can_alter_field_definition? }
      it { is_expected.to eq true }
    end

    describe '#can_delete_feature?' do
      subject { layer.can_delete_feature? }
      it { is_expected.to eq true }
    end

    describe '#strings_are_utf_8?' do
      subject { layer.strings_are_utf_8? }
      it { is_expected.to eq false }
    end

    describe '#supports_transactions?' do
      subject { layer.supports_transactions? }
      it { is_expected.to eq false }
    end

    describe '#supports_curve_geometries?' do
      subject { layer.supports_curve_geometries? }
      it { is_expected.to eq true }
    end
  end
end
