# typed: false
# frozen_string_literal: true

require 'ogr'

RSpec.describe 'OGR::Layer' do
  let(:data_source) do
    OGR::DataSource.open('spec/support/shapefiles/states_21basic/states.shp', 'r')
  end

  let(:layer0) do
    data_source.layer(0)
  end

  subject do
    layer0
  end

  describe '#name' do
    subject { layer0.name }
    it { is_expected.to eq 'states' }
  end

  describe '#geometry_type' do
    subject { layer0.geometry_type }
    it { is_expected.to eq :wkbPolygon }
  end

  describe '#feature_count' do
    subject { layer0.feature_count }
    it { is_expected.to eq 51 }
  end

  describe '#feature' do
    subject { layer0.feature(0) }
    it { is_expected.to be_a OGR::Feature }
  end

  describe '#next_feature' do
    subject { layer0.next_feature }
    after { subject.destroy! }
    it { is_expected.to be_a OGR::Feature }
  end

  describe '#features_read' do
    subject { layer0.features_read }
    it { is_expected.to be >= 0 }
  end

  describe '#feature_definition' do
    subject { layer0.feature_definition }
    it { is_expected.to be_a OGR::FeatureDefinition }
  end

  describe '#spatial_reference' do
    subject { layer0.spatial_reference }
    it { is_expected.to be_a OGR::SpatialReference }
  end

  describe '#extent' do
    subject { layer0.extent }
    it { is_expected.to be_a OGR::Envelope }
  end

  describe '#fid_column' do
    subject { layer0.fid_column }
    it { is_expected.to be_a String }
    it { is_expected.to be_empty }
  end

  describe '#geometry_column' do
    subject { layer0.geometry_column }
    it { is_expected.to be_a String }
    it { is_expected.to be_empty }
  end

  describe '#style_table' do
    subject { layer0.style_table }
    it { is_expected.to be_nil }
  end
end
