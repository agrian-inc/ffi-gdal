# typed: false
# frozen_string_literal: true

require 'ogr/geometry_field_definition'
require 'ogr/spatial_reference'

RSpec.describe OGR::GeometryFieldDefinition do
  subject(:geometry_field_definition) { described_class.new('test gfld') }

  describe '#name' do
    it 'returns the name' do
      expect(subject.name).to eq 'test gfld'
    end
  end

  describe '#name= + #name' do
    it 'assigns a new name' do
      subject.name = 'bobo'
      expect(subject.name).to eq 'bobo'
    end
  end

  describe '#type' do
    it 'returns the type' do
      expect(subject.type).to eq :wkbUnknown
    end
  end

  describe '#type= + #type' do
    it 'assigns a new type' do
      subject.type = :wkbPolygon
      expect(subject.type).to eq :wkbPolygon
    end
  end

  describe '#spatial_reference' do
    context 'default' do
      subject { geometry_field_definition.spatial_reference }
      it { is_expected.to be_nil }
    end
  end

  describe '#spatial_reference= + #spatial_reference' do
    it 'assigns the new SpatialReference' do
      new_spatial_reference = OGR::SpatialReference.new_from_epsg 4326
      subject.spatial_reference = new_spatial_reference
      expect(subject.spatial_reference.authority_code.to_i).to eq 4326
    end
  end

  describe '#ignored?' do
    context 'default' do
      it { is_expected.to_not be_ignored }
    end
  end

  describe '#ignore=' do
    context 'setting to true' do
      it 'sets the value to true' do
        subject.ignore = true
        expect(subject).to be_ignored
      end
    end
  end
end
