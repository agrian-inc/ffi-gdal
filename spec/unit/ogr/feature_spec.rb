# typed: false
# frozen_string_literal: true

require 'date'
require 'ogr/feature'
require 'ogr/field'

RSpec.describe OGR::Feature do
  let(:integer_field_def) { OGR::FieldDefinition.new('test integer field', :OFTInteger) }
  let(:integer_list_field_def) { OGR::FieldDefinition.new('test integer list field', :OFTIntegerList) }
  let(:real_field_def) { OGR::FieldDefinition.new('test real field', :OFTReal) }
  let(:real_list_field_def) { OGR::FieldDefinition.new('test real list field', :OFTRealList) }
  let(:string_field_def) { OGR::FieldDefinition.new('test string field', :OFTString) }
  let(:string_list_field_def) { OGR::FieldDefinition.new('test string list field', :OFTStringList) }
  let(:binary_field_def) { OGR::FieldDefinition.new('test binary field', :OFTBinary) }
  let(:date_field_def) { OGR::FieldDefinition.new('test date field', :OFTDate) }

  let(:feature_definition) do
    fd = OGR::FeatureDefinition.new('test FD')

    fd.add_field_definition(integer_field_def)        # 0
    fd.add_field_definition(integer_list_field_def)   # 1
    fd.add_field_definition(real_field_def)           # 2
    fd.add_field_definition(real_list_field_def)      # 3
    fd.add_field_definition(string_field_def)         # 4
    fd.add_field_definition(string_list_field_def)    # 5
    fd.add_field_definition(binary_field_def)         # 6
    fd.add_field_definition(date_field_def)           # 7

    gfd = fd.geometry_field_definition(0)
    gfd.type = :wkbPoint
    gfd.name = 'test point'

    fd
  end

  let(:empty_feature_definition) do
    OGR::FeatureDefinition.new('empty test FD')
  end

  describe '.new' do
    context 'param is not a FeatureDefinition or pointer to a FeatureDefinition' do
      it 'raises an OGR::InvalidFeature' do
        expect do
          described_class.new('not a pointer')
        end.to raise_exception OGR::InvalidFeature
      end
    end
  end

  subject(:feature) { described_class.new(feature_definition) }

  describe '#clone' do
    it 'returns a new Feature' do
      expect(subject.clone).to be_a OGR::Feature
    end
  end

  describe '#field_count' do
    context 'no fields' do
      subject { empty_feature_definition.field_count }
      it { is_expected.to be_zero }
    end

    context 'with fields' do
      it 'returns the number of fields that have been added' do
        expect(subject.field_count).to eq 8
      end
    end
  end

  describe '#set_field_integer + #field_as_integer' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_integer(0, 123)
        expect(subject.field_as_integer(0)).to eq 123
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_integer(100, 123)
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not an integer' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_integer(0, 'meow')
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_integer_list + #field_as_integer_list' do
    context 'to a valid index' do
      it 'adds the integer list' do
        subject.set_field_integer_list(1, [1, 2, 3])
        expect(subject.field_as_integer_list(1)).to eq [1, 2, 3]
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_integer_list(100, [1, 2, 3])
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not an array of integers' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_integer_list(1, ['meow'])
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_double + #field_as_double' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_double(2, 123.123)
        expect(subject.field_as_double(2)).to eq 123.123
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_double(100, 123.123)
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not a float' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_double(2, 'meow')
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_double_list + #field_as_double_list' do
    context 'to a valid index' do
      it 'adds the double list' do
        subject.set_field_double_list(3, [1.1, 2.1, 3.1])
        expect(subject.field_as_double_list(3)).to eq [1.1, 2.1, 3.1]
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_double_list(100, [1.1, 2.1, 3.1])
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not an array of doubles' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_double_list(3, ['meow'])
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_string + #field_as_string' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_string(4, 'test string')
        expect(subject.field_as_string(4)).to eq 'test string'
      end
    end

    context 'to an invalid valid index' do
      it 'raises a GDAL::Error' do
        expect do
          subject.set_field_string(100, 'test string')
        end.to raise_exception GDAL::Error
      end
    end

    context 'value is not a string' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_string(4, 123)
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_string_list' do
    context 'to a valid index' do
      it 'adds the string list' do
        subject.set_field_string_list(5, %w[one two three])
        expect(subject.field_as_string_list(5)).to eq %w[one two three]
      end
    end

    context 'to an invalid valid index' do
      it 'raises a GDAL::Error' do
        expect do
          subject.set_field_string_list(100, [1, 2, 3])
        end.to raise_exception GDAL::Error, 'Invalid index : 100'
      end
    end

    context 'value is not an array of strings' do
      it 'returns an Array of Strings' do
        subject.set_field_integer_list(5, [1, 2, 3])
        expect(subject.field_as_string_list(5)).to eq %w[1 2 3]
      end
    end
  end

  describe '#set_field_raw + #field_as_raw' do
    let(:integer_field) do
      f = OGR::Field.new
      f.integer = 1

      f
    end

    let(:integer_list_field) do
      f = OGR::Field.new
      f.integer_list = [1, 2, 3]

      f
    end

    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_raw(0, integer_field)
        expect(subject.field_as_integer(0)).to eq 1
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_raw(100, integer_field)
        end.to raise_exception GDAL::Error
      end
    end
  end

  describe '#set_field_binary + #field_as_binary' do
    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_binary(6, [65, 66, 67, 68, 69].pack('C*'))
        expect(subject.field_as_binary(6)).to eq [65, 66, 67, 68, 69]
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_binary(100, 123)
        end.to raise_exception TypeError
      end
    end

    context 'value is not binary' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_binary(6, 123)
        end.to raise_exception TypeError
      end
    end
  end

  describe '#set_field_date_time + #field_as_date_time' do
    let(:date_time) { DateTime.now }

    context 'to a valid index' do
      it 'adds the field' do
        subject.set_field_date_time(7, date_time)
        expect(subject.field_as_date_time(7).httpdate).to eq date_time.httpdate
      end
    end

    context 'to an invalid valid index' do
      it 'adds the field' do
        expect do
          subject.set_field_binary(100, 123)
        end.to raise_exception TypeError
      end
    end

    context 'value is not binary' do
      it 'raises a TypeError' do
        expect do
          subject.set_field_binary(6, 123)
        end.to raise_exception TypeError
      end
    end
  end
  describe '#field_definition' do
    context 'field exists at the given index' do
      it 'returns the FieldDefinition' do
        expect(subject.field_definition(0)).to be_a OGR::FieldDefinition
      end
    end

    context 'field does not exist at the given index' do
      it 'raises a GDAL::Error' do
        expect { subject.field_definition(123) }.to raise_exception GDAL::Error
      end
    end
  end

  describe 'field_index' do
    context 'field exists with the given name' do
      it "returns the FieldDefinition's index" do
        expect(subject.field_index('test binary field')).to eq 6
      end
    end

    context 'field does not exist with the given name' do
      it 'returns nil' do
        expect(subject.field_index('asdfadsasd')).to be_nil
      end
    end
  end

  describe '#field_set?' do
    context 'field at the given index is not set' do
      it 'returns false' do
        expect(subject.field_set?(0)).to eq false
      end
    end

    context 'field at the given index is set' do
      before do
        subject.set_field_string(0, 'Pants')
      end

      it 'returns true' do
        expect(subject.field_set?(0)).to eq true
      end
    end
  end

  describe '#unset_field + #field_set?' do
    context 'field is set' do
      it 'removes the field' do
        subject.unset_field(0)
        expect(subject.field_set?(0)).to eq false
      end
    end

    context 'field is not set' do
      it 'raises a GDAL::Error' do
        expect { subject.unset_field(100) }.to raise_exception GDAL::Error
      end
    end
  end
end
