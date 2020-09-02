# typed: false
# frozen_string_literal: true

require 'ogr/data_source'

RSpec.describe OGR::DataSource do
  context 'Memory datasource' do
    subject(:data_source) do
      OGR::Driver.by_name('Memory').create_data_source('test')
    end

    describe '#can_create_layer?' do
      subject { data_source.can_create_layer? }
      it { is_expected.to eq true }
    end

    describe '#can_delete_layer?' do
      subject { data_source.can_delete_layer? }
      it { is_expected.to eq true }
    end

    describe '#can_create_geometry_field_after_create_layer?' do
      subject { data_source.can_create_geometry_field_after_create_layer? }
      it { is_expected.to eq true }
    end

    describe '#supports_curve_geometries?' do
      subject { data_source.supports_curve_geometries? }
      it { is_expected.to eq true }
    end
  end
end
