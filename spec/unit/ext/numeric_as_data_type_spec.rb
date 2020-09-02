# typed: false
# frozen_string_literal: true

RSpec.describe Numeric do
  let(:integer_data_types) do
    %i[GDT_Byte GDT_UInt16 GDT_Int16 GDT_UInt32 GDT_Int32]
  end

  let(:float_data_types) do
    %i[GDT_Float32 GDT_Float64]
  end

  let(:complex_data_types) do
    %i[GDT_CInt16 GDT_CInt32 GDT_CFloat32 GDT_CFloat64]
  end

  shared_examples_for 'a numeric converted to GDAL' do
    context 'integer data types' do
      it 'returns an Integer' do
        integer_data_types.each do |data_type|
          expect(subject.to_data_type(data_type)).to eql 1
          expect(subject.to_data_type(data_type)).to be_an Integer
        end
      end
    end

    context 'float data types' do
      it 'returns a Float' do
        float_data_types.each do |data_type|
          expect(subject.to_data_type(data_type)).to eql 1.0
          expect(subject.to_data_type(data_type)).to be_a Float
        end
      end
    end

    context 'complex data types' do
      it 'returns a Complex' do
        complex_data_types.each do |data_type|
          expect(subject.to_data_type(data_type)).to eql(1 + 0i).or eql(1.0 + 0i)
          expect(subject.to_data_type(data_type)).to be_a Complex
        end
      end
    end
  end

  context 'Integers' do
    subject { 1 }

    it_behaves_like 'a numeric converted to GDAL'

    context 'unknown data type' do
      it 'returns self' do
        expect(subject.to_data_type('meow')).to eql 1
        expect(subject.to_data_type('meow')).to be_a Integer
      end
    end
  end

  context 'Floats' do
    context 'subject round down to 1' do
      subject { 1.0 }

      it_behaves_like 'a numeric converted to GDAL'

      context 'unknown data type' do
        it 'returns self' do
          expect(subject.to_data_type('meow')).to eql subject
          expect(subject.to_data_type('meow')).to be_a Float
        end
      end
    end

    context 'subject rounds up to 2' do
      subject { 1.8 }

      context 'integer data types' do
        it 'returns an Integer' do
          integer_data_types.each do |data_type|
            expect(subject.to_data_type(data_type)).to eql 1
            expect(subject.to_data_type(data_type)).to be_an Integer
          end
        end
      end
    end
  end

  context 'Complexes' do
    context 'subject round down to 1' do
      subject { 1 + 0i }

      it_behaves_like 'a numeric converted to GDAL'

      context 'unknown data type' do
        it 'returns self' do
          expect(subject.to_data_type('meow')).to eql subject
          expect(subject.to_data_type('meow')).to be_a Complex
        end
      end
    end

    context 'subject rounds up to 2' do
      subject { 1.8 + 0i }

      context 'integer data types' do
        it 'returns an Integer' do
          integer_data_types.each do |data_type|
            expect(subject.to_data_type(data_type)).to eql 1
            expect(subject.to_data_type(data_type)).to be_an Integer
          end
        end
      end
    end
  end
end
