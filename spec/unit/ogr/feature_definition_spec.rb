# typed: false
# frozen_string_literal: true

require 'ogr/feature_definition'

RSpec.describe OGR::FeatureDefinition do
  subject(:feature_definition) do
    fd = described_class.new('spec feature definition')
    fd.geometry_type = :wkbMultiPolygon
    fd
  end

  let(:field) { OGR::FieldDefinition.new('test field', :OFTString) }

  describe '#name' do
    it 'returns the name given to it' do
      expect(subject.name).to eq 'spec feature definition'
    end
  end

  describe '#field_count' do
    context 'no fields' do
      subject { feature_definition.field_count }
      it { is_expected.to be_zero }
    end

    context 'with fields' do
      before { feature_definition.add_field_definition(field) }

      it 'returns the number of fields that have been added' do
        expect(subject.field_count).to eq 1
      end
    end
  end

  describe '#field_definition' do
    context 'field definition at the given index does not exist' do
      it 'raises a RuntimeError' do
        expect { subject.field_definition(0) }.to raise_exception RuntimeError
      end
    end

    context 'field definition at the given index exists' do
      before { subject.add_field_definition(field) }

      it 'returns the Field' do
        expect(subject.field_definition(0)).to be_a OGR::FieldDefinition
      end
    end
  end

  describe '#add_field_definition + #field_definition' do
    context 'param is not a FieldDefinition' do
      it 'raises' do
        expect do
          subject.add_field_definition('not a pointer')
        end.to raise_exception OGR::InvalidFieldDefinition
      end
    end

    context 'param is a FieldDefinition' do
      let(:field) { OGR::FieldDefinition.new('test field', :OFTString) }

      it 'adds the field' do
        subject.add_field_definition(field)
        expect(subject.field_definition(0)).to be_a OGR::FieldDefinition
      end
    end
  end

  describe '#delete_field_definition' do
    context 'no fields' do
      it 'raises an OGR::Failure' do
        expect do
          subject.delete_field_definition(0)
        end.to raise_exception OGR::Failure
      end
    end

    context 'valid field' do
      before { subject.add_field_definition(field) }

      it 'deletes the field' do
        subject.delete_field_definition(0)

        expect do
          subject.delete_field_definition(0)
        end.to raise_exception OGR::Failure
      end
    end
  end

  describe '#field_index' do
    context 'field with requested name does not exist' do
      it 'returns nil' do
        expect(subject.field_index('things')).to be_nil
      end
    end

    context 'field with requested name exists' do
      let(:field) { OGR::FieldDefinition.new('test field', :OFTString) }
      before { subject.add_field_definition(field) }

      it "returns the FieldDefinition's index" do
        expect(subject.field_index('test field')).to be_zero
      end
    end
  end

  describe '#geometry_type' do
    context 'default' do
      subject(:feature_definition) do
        described_class.new('spec feature definition')
      end

      it 'is :wkbUnknown' do
        expect(subject.geometry_type).to eq :wkbUnknown
      end
    end
  end

  describe '#geometry_type= + #geometry_type' do
    context 'valid geometry type' do
      it 'assigns the new geometry type' do
        subject.geometry_type = :wkbPoint
        expect(subject.geometry_type).to eq :wkbPoint
      end
    end

    context 'invalid geometry type' do
      it 'raises an ArgumenError' do
        expect { subject.geometry_type = :bubbles }
          .to raise_exception ArgumentError
      end
    end
  end

  describe '#geometry_ignored?' do
    context 'default' do
      subject { feature_definition.geometry_ignored? }
      it { is_expected.to eq false }
    end
  end

  describe '#ignore_geometry! + #geometry_ignored?' do
    context 'set to ignore' do
      it 'causes the geometry to be ignored' do
        subject.ignore_geometry!
        expect(subject.geometry_ignored?).to eq true
      end
    end

    context 'set to not ignore' do
      it 'causes the geometry to be ignored' do
        subject.ignore_geometry! ignore: false
        expect(subject.geometry_ignored?).to eq false
      end
    end
  end

  describe '#style_ignored?' do
    context 'default' do
      subject { feature_definition.style_ignored? }
      it { is_expected.to eq false }
    end
  end

  describe '#ignore_style! + #style_ignored?' do
    context 'set to ignore' do
      it 'causes the style to be ignored' do
        subject.ignore_style!
        expect(subject.style_ignored?).to eq true
      end
    end

    context 'set to not ignore' do
      it 'causes the style to be ignored' do
        subject.ignore_style! ignore: false
        expect(subject.style_ignored?).to eq false
      end
    end
  end

  describe '#geometry_field_count' do
    context 'default' do
      subject { feature_definition.geometry_field_count }
      it { is_expected.to eq 1 }
    end
  end

  describe '#geometry_field_definition' do
    context 'default, at 0' do
      it 'returns an OGR::GeometryFieldDefinition' do
        expect(subject.geometry_field_definition(0))
          .to be_a OGR::GeometryFieldDefinition
      end

      it 'has a type that is the same as the feature' do
        gfd = subject.geometry_field_definition(0)
        expect(subject.geometry_type).to eq gfd.type
      end
    end
  end

  describe '#add_geometry_field_definition + #geometry_field_definition' do
    let(:geometry_field_definition) do
      OGR::GeometryFieldDefinition.new('test1', :wkbPolygon)
    end

    it 'adds the geometry_field_definition' do
      expect do
        subject.add_geometry_field_definition geometry_field_definition
      end.to change { subject.geometry_field_count }.by 1
    end
  end

  describe '#delete_geometry_field_definition' do
    context 'no geometry field definition at given index' do
      it 'raises an OGR::Failure' do
        expect do
          subject.delete_geometry_field_definition(123)
        end.to raise_exception OGR::Failure
      end
    end

    context 'geometry field definition exists at given index' do
      let(:geometry_field_definition) do
        OGR::GeometryFieldDefinition.new('test1', :wkbPolygon)
      end

      before { subject.add_geometry_field_definition(geometry_field_definition) }

      it 'deletes the gfld' do
        expect do
          subject.delete_geometry_field_definition(1)
        end.to change { subject.geometry_field_count }.by(-1)
      end
    end
  end

  describe '#same?' do
    context 'is the same as the other' do
      let(:other_feature_definition) do
        df = described_class.new('spec feature definition')
        df.geometry_type = :wkbMultiPolygon
        df
      end

      it 'returns true' do
        expect(subject.same?(other_feature_definition)).to eq true
      end
    end

    context 'not the same as the other' do
      let(:other_feature_definition) do
        described_class.new('other feature definition')
      end

      it 'returns false' do
        expect(subject.same?(other_feature_definition)).to eq false
      end
    end
  end
end
