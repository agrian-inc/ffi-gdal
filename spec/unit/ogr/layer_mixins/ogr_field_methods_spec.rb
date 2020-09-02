# typed: false
# frozen_string_literal: true

require 'ogr/layer'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

  describe '#create_field + #find_field_index' do
    context 'creation not supported' do
      before do
        expect(subject).to receive(:can_create_field?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.create_field(OGR::FieldDefinition.new('test', :OFTInteger)) }
          .to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'creation is supported' do
      it 'can create an OFTInteger' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTInteger))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTIntegerList' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTIntegerList))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTReal' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTReal))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTRealList' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTRealList))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTString' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTString))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTStringList' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTStringList))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTWideString' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTWideString))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTWideStringList' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTWideStringList))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTBinary' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTBinary))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTDate' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTDate))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTTime' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTTime))
        expect(subject.find_field_index('test field')).to be_zero
      end

      it 'can create an OFTDateTime' do
        subject.create_field(OGR::FieldDefinition.new('test field', :OFTDateTime))
        expect(subject.find_field_index('test field')).to be_zero
      end
    end
  end

  describe '#delete_field + #create_field' do
    context 'delete not supported' do
      before do
        expect(subject).to receive(:can_delete_field?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.delete_field(0) }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'delete is supported' do
      context 'field exists at index' do
        before do
          fd = OGR::FieldDefinition.new('test field', :OFTInteger)
          subject.create_field(fd)
        end

        it 'can delete the field' do
          expect(subject.delete_field(0)).to be_nil
        end
      end

      context 'field does not exist at index' do
        it 'raises a GDAL::UnsupportedOperation' do
          expect { subject.delete_field(1) }.to raise_exception GDAL::UnsupportedOperation
        end
      end
    end
  end

  describe '#reorder_fields + #create_field' do
    context 'reordering not supported' do
      before do
        expect(subject).to receive(:can_reorder_fields?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.reorder_fields(1, 0) }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'reordering is supported' do
      context 'field does not exist at one of the given indexes' do
        it 'returns false' do
          expect(subject.reorder_fields(1, 0)).to eq false
        end
      end

      context 'no fields given' do
        it 'returns false' do
          expect(subject.reorder_fields).to eq false
        end
      end

      context 'fields exist' do
        before do
          fd0 = OGR::FieldDefinition.new('field0', :OFTInteger)
          fd1 = OGR::FieldDefinition.new('field1', :OFTString)
          subject.create_field(fd0)
          subject.create_field(fd1)
        end

        it 'returns nil and reorders the fields' do
          expect(subject.find_field_index('field0')).to eq 0
          expect(subject.find_field_index('field1')).to eq 1

          expect(subject.reorder_fields(1, 0)).to be_nil

          expect(subject.find_field_index('field0')).to eq 1
          expect(subject.find_field_index('field1')).to eq 0
        end

        it "updates the feature definition's field definitions" do
          expect(subject.feature_definition.field_definition(0).name).to eq 'field0'
          expect(subject.feature_definition.field_definition(1).name).to eq 'field1'
        end
      end
    end
  end

  describe '#reorder_field + #create_field' do
    context 'reordering not supported' do
      before do
        expect(subject).to receive(:can_reorder_fields?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.reorder_field(1, 0) }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'reordering is supported' do
      context 'field does not exist at one of the given indexes' do
        it 'raises a GDAL::UnsupportedOperation' do
          expect { subject.reorder_field(1, 0) }.to raise_exception GDAL::UnsupportedOperation
        end
      end

      context 'fields exist' do
        before do
          fd0 = OGR::FieldDefinition.new('field0', :OFTInteger)
          fd1 = OGR::FieldDefinition.new('field1', :OFTString)
          subject.create_field(fd0)
          subject.create_field(fd1)
        end

        it 'returns nil and reorders the fields' do
          expect(subject.find_field_index('field0')).to eq 0
          expect(subject.find_field_index('field1')).to eq 1

          expect(subject.reorder_field(1, 0)).to be_nil

          expect(subject.find_field_index('field0')).to eq 1
          expect(subject.find_field_index('field1')).to eq 0
        end

        it "updates the feature definition's field definitions" do
          expect(subject.feature_definition.field_definition(0).name).to eq 'field0'
          expect(subject.feature_definition.field_definition(1).name).to eq 'field1'
        end
      end
    end
  end

  describe '#alter_field_definition + #create_field' do
    context 'altering not supported' do
      before do
        expect(subject).to receive(:can_alter_field_definition?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect do
          subject.alter_field_definition(123, OGR::FieldDefinition.new('blah', :OFTString), OGR::Layer::ALTER_ALL_FLAG)
        end.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'altering is supported' do
      let(:string_field_def) do
        fd = OGR::FieldDefinition.new('StringField', :OFTString)
        fd.width = 16

        fd
      end

      let(:int_field_def) do
        fd = OGR::FieldDefinition.new('IntField', :OFTInteger)
        fd.width = 4

        fd
      end

      let(:real_field_def) do
        fd = OGR::FieldDefinition.new('RealField', :OFTReal)
        fd.width = 8

        fd
      end

      context 'no field at given index' do
        it 'raises a GDAL::UnsupportedOperation' do
          expect do
            subject.alter_field_definition(123, int_field_def, OGR::Layer::ALTER_ALL_FLAG)
          end.to raise_exception GDAL::UnsupportedOperation
        end
      end

      context 'field exists at given index' do
        context 'ALTER_NAME_FLAG' do
          before { subject.create_field(string_field_def) }

          it 'only alters the name of the field' do
            subject.alter_field_definition(0, int_field_def, OGR::Layer::ALTER_NAME_FLAG)

            expect(subject.feature_definition.field_definition(0).name).to eq 'IntField'
            expect(subject.feature_definition.field_definition(0).type).to eq :OFTString
            expect(subject.feature_definition.field_definition(0).width).to eq 16
          end
        end

        context 'ALTER_TYPE_FLAG' do
          context 'convert OFTString to OFTInteger' do
            before { subject.create_field(string_field_def) }

            it 'raises a GDAL::UnsupportedOperation' do
              expect do
                subject.alter_field_definition(0, int_field_def, OGR::Layer::ALTER_TYPE_FLAG)
              end.to raise_exception GDAL::UnsupportedOperation
            end
          end

          context 'convert OFTInteger to OFTString' do
            before { subject.create_field(int_field_def) }

            it 'only alters the type of the field' do
              subject.alter_field_definition(0, string_field_def, OGR::Layer::ALTER_TYPE_FLAG)

              expect(subject.feature_definition.field_definition(0).name).to eq 'IntField'
              expect(subject.feature_definition.field_definition(0).type).to eq :OFTString
              expect(subject.feature_definition.field_definition(0).width).to eq 4
            end
          end

          context 'convert OFTInteger to OFTReal' do
            before { subject.create_field(int_field_def) }

            it 'only alters the type of the field' do
              subject.alter_field_definition(0, real_field_def, OGR::Layer::ALTER_TYPE_FLAG)

              expect(subject.feature_definition.field_definition(0).name).to eq 'IntField'
              expect(subject.feature_definition.field_definition(0).type).to eq :OFTReal
              expect(subject.feature_definition.field_definition(0).width).to eq 4
            end
          end

          context 'convert OFTReal to OFTInteger' do
            before { subject.create_field(real_field_def) }

            it 'raises a GDAL::UnsupportedOperation' do
              expect do
                subject.alter_field_definition(0, int_field_def, OGR::Layer::ALTER_TYPE_FLAG)
              end.to raise_exception GDAL::UnsupportedOperation
            end
          end
        end

        context 'ALTER_WIDTH_PRECISION_FLAG' do
          before { subject.create_field(string_field_def) }

          it 'only alters the width of the field' do
            subject.alter_field_definition(0, int_field_def, OGR::Layer::ALTER_WIDTH_PRECISION_FLAG)

            expect(subject.feature_definition.field_definition(0).name).to eq 'StringField'
            expect(subject.feature_definition.field_definition(0).type).to eq :OFTString
            expect(subject.feature_definition.field_definition(0).width).to eq 4
          end
        end

        context 'ALTER_ALL_FLAG' do
          context 'convert OFTString to OFTInteger' do
            before { subject.create_field(string_field_def) }

            it 'raises a GDAL::UnsupportedOperation' do
              expect do
                subject.alter_field_definition(0, int_field_def, OGR::Layer::ALTER_ALL_FLAG)
              end.to raise_exception GDAL::UnsupportedOperation
            end
          end

          context 'convert OFTInteger to OFTString' do
            before { subject.create_field(int_field_def) }

            it 'alters all attributes of the field' do
              subject.alter_field_definition(0, string_field_def, OGR::Layer::ALTER_ALL_FLAG)

              expect(subject.feature_definition.field_definition(0).name).to eq 'StringField'
              expect(subject.feature_definition.field_definition(0).type).to eq :OFTString
              expect(subject.feature_definition.field_definition(0).width).to eq 16
            end
          end

          context 'convert OFTInteger to OFTReal' do
            before { subject.create_field(int_field_def) }

            it 'alters all attributes of the field' do
              subject.alter_field_definition(0, real_field_def, OGR::Layer::ALTER_ALL_FLAG)

              expect(subject.feature_definition.field_definition(0).name).to eq 'RealField'
              expect(subject.feature_definition.field_definition(0).type).to eq :OFTReal
              expect(subject.feature_definition.field_definition(0).width).to eq 8
            end
          end

          context 'convert OFTReal to OFTInteger' do
            before { subject.create_field(real_field_def) }

            it 'raises a GDAL::UnsupportedOperation' do
              expect do
                subject.alter_field_definition(0, int_field_def, OGR::Layer::ALTER_ALL_FLAG)
              end.to raise_exception GDAL::UnsupportedOperation
            end
          end
        end
      end
    end
  end

  describe '#find_field_index' do
    context 'field with name does not exist' do
      it 'returns nil' do
        expect(subject.find_field_index('meow')).to be_nil
      end
    end

    context 'field with name exists' do
      before { subject.create_field(OGR::FieldDefinition.new('meow', :OFTString)) }

      it 'returns the index' do
        expect(subject.find_field_index('meow')).to be_zero
      end
    end
  end

  describe '#create_geometry_field' do
    let(:geometry_field_def) { OGR::GeometryFieldDefinition.new('geofield0') }

    context 'creation not supported' do
      before do
        expect(subject).to receive(:can_create_geometry_field?).and_return false
      end

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.create_geometry_field(geometry_field_def) }
          .to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'creation is supported' do
      it 'returns nil' do
        expect(subject.create_geometry_field(geometry_field_def)).to be_nil
      end
    end
  end

  describe '#set_ignored_fields' do
    context 'no fields given' do
      it 'returns false' do
        expect(subject.set_ignored_fields).to eq false
      end
    end

    context 'invalid field names given' do
      it 'raises an OGR::Failure' do
        expect { subject.set_ignored_fields('meow', 'bobo') }
          .to raise_exception OGR::Failure
      end
    end

    context 'valid field names given' do
      before do
        subject.create_field(OGR::FieldDefinition.new('meow', :OFTInteger))
        subject.create_field(OGR::FieldDefinition.new('bobo', :OFTInteger))
      end

      it 'returns nil' do
        expect(subject.set_ignored_fields('meow', 'bobo')).to be_nil
      end
    end
  end
end
