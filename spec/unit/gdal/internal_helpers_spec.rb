# typed: false
# frozen_string_literal: true

require 'gdal/internal_helpers'
require 'ogr/spatial_reference'
require 'gdal/dataset'

RSpec.describe GDAL::InternalHelpers do
  subject(:tester) do
    module Tester
      include GDAL::InternalHelpers
    end
  end

  describe '._pointer' do
    context 'variable is a kind of the klass that was passed in' do
      let(:variable) { OGR::SpatialReference.new }

      it "returns the variable's pointer with autorelease = true" do
        expect(variable.c_pointer).to receive(:autorelease=).with(true)
        expect(subject._pointer(OGR::SpatialReference, variable)).to eq variable.c_pointer
      end
    end

    context 'variable is an FFI::Pointer' do
      let(:variable) { FFI::MemoryPointer.new(:pointer) }

      it 'returns the pointer with autorelease = true' do
        expect(variable).to receive(:autorelease=).with(true)
        expect(subject._pointer(GDAL::Dataset, variable)).to eq variable
      end
    end

    context 'variable is nil' do
      it 'returns nil' do
        expect(subject._pointer(GDAL::Dataset, nil, warn_on_nil: false)).to be_nil
      end
    end
  end

  describe '._string_array_to_pointer' do
    context 'an array' do
      let(:array) { ['one', 2, 3.0, :four] }

      it 'returns a pointer that contains the array values as strings' do
        pointer = subject._string_array_to_pointer(array)
        expect(pointer).to be_an FFI::MemoryPointer
        expect(pointer.get_array_of_string(0)).to eq %w[one 2 3.0 four]
      end
    end

    context 'not an array' do
      it 'raises an error about no responding to #map' do
        expect do
          subject._string_array_to_pointer('blarg')
        end.to raise_exception NoMethodError
      end
    end
  end

  describe '._gdal_data_type_to_ffi' do
    context 'data type is :GDT_Byte' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Byte) }
      it { is_expected.to eq :uchar }
    end

    context 'data type is :GDT_UInt16' do
      subject { tester._gdal_data_type_to_ffi(:GDT_UInt16) }
      it { is_expected.to eq :uint16 }
    end

    context 'data type is :GDT_Int16' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Int16) }
      it { is_expected.to eq :int16 }
    end

    context 'data type is :GDT_UInt32' do
      subject { tester._gdal_data_type_to_ffi(:GDT_UInt32) }
      it { is_expected.to eq :uint32 }
    end

    context 'data type is :GDT_Int32' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Int32) }
      it { is_expected.to eq :int32 }
    end

    context 'data type is :GDT_Float32' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Float32) }
      it { is_expected.to eq :float }
    end

    context 'data type is :GDT_Float64' do
      subject { tester._gdal_data_type_to_ffi(:GDT_Float64) }
      it { is_expected.to eq :double }
    end

    context 'data type is not one listed' do
      it 'raises a GDAL::InvalidDataType' do
        expect { tester._gdal_data_type_to_ffi(:blargh) }
          .to raise_exception(GDAL::InvalidDataType)
      end
    end
  end

  describe '._read_pointer' do
    context 'length is 1' do
      let(:pointer) do
        p = FFI::MemoryPointer.new(:int16)
        p.write_int16(12_345)

        p
      end

      it 'returns the data value' do
        expect(GDAL._read_pointer(pointer, :GDT_Int16)).to eq(12_345)
      end
    end

    context 'length is > 1' do
      let(:pointer) do
        p = FFI::MemoryPointer.new(:int16, 2)
        p.write_array_of_int16([12_345, 222])

        p
      end

      it 'returns the data value' do
        expect(GDAL._read_pointer(pointer, :GDT_Int16, 2)).to eq([12_345, 222])
      end
    end
  end

  describe '._write_pointer' do
    context 'data is not an Array' do
      let(:pointer) { FFI::MemoryPointer.new(:int16) }

      it 'writes the single value to the pointer' do
        expect(pointer).to receive(:write_int16).with(12_345)
        GDAL._write_pointer(pointer, :GDT_Int16, 12_345)
      end
    end

    context 'data is an Array' do
      let(:pointer) { FFI::MemoryPointer.new(:int16, 2) }

      it 'writes the values to the pointer' do
        expect(pointer).to receive(:write_array_of_int16).with([12_345, 222])
        GDAL._write_pointer(pointer, :GDT_Int16, [12_345, 222])
      end
    end
  end

  describe '._supported?' do
    context 'function is supported' do
      subject { tester._supported?(:GDALAllRegister) }
      it { is_expected.to eq true }
    end

    context 'function is not supported' do
      subject { tester._supported?(:darrells) }
      it { is_expected.to eq false }
    end
  end

  describe '._gdal_data_type_to_narray' do
    subject { GDAL._gdal_data_type_to_narray(data_type) }

    context 'data_type is :GDT_Byte' do
      let(:data_type) { :GDT_Byte }
      it { is_expected.to eq(:byte) }
    end

    context 'data_type is :GDT_Int16' do
      let(:data_type) { :GDT_Int16 }
      it { is_expected.to eq(:sint) }
    end

    context 'data_type is :GDT_UInt16' do
      let(:data_type) { :GDT_UInt16 }
      it { is_expected.to eq(:int) }
    end

    context 'data_type is :GDT_Int32' do
      let(:data_type) { :GDT_Int32 }
      it { is_expected.to eq(:int) }
    end

    context 'data_type is :GDT_UInt32' do
      let(:data_type) { :GDT_UInt32 }
      it { is_expected.to eq(:int) }
    end

    context 'data_type is :GDT_Float32' do
      let(:data_type) { :GDT_Float32 }
      it { is_expected.to eq(:float) }
    end

    context 'data_type is :GDT_Float64' do
      let(:data_type) { :GDT_Float64 }
      it { is_expected.to eq(:dfloat) }
    end

    context 'data_type is :GDT_CInt16' do
      let(:data_type) { :GDT_CInt16 }
      it { is_expected.to eq(:scomplex) }
    end

    context 'data_type is :GDT_CInt32' do
      let(:data_type) { :GDT_CInt32 }
      it { is_expected.to eq(:scomplex) }
    end

    context 'data_type is :GDT_CFloat32' do
      let(:data_type) { :GDT_CFloat32 }
      it { is_expected.to eq(:complex) }
    end

    context 'data_type is :GDT_CFloat64' do
      let(:data_type) { :GDT_CFloat64 }
      it { is_expected.to eq(:dcomplex) }
    end

    context 'unknown data_type' do
      it 'raises a GDAL::InvalidDataType exception' do
        expect { GDAL._gdal_data_type_to_narray(:meow) }
          .to raise_exception(GDAL::InvalidDataType)
      end
    end
  end

  describe '._narray_from_data_type' do
    context '0 narray_args and known GDAL data_type' do
      subject { GDAL._narray_from_data_type(:GDT_Byte) }
      it { is_expected.to be_a NArray }

      it 'has size 0' do
        expect(subject.size).to be_zero
      end

      it 'has shape []' do
        expect(subject.shape).to eq([])
      end
    end

    context '1 narray_args and known GDAL data_type' do
      subject { GDAL._narray_from_data_type(:GDT_Byte, 2) }
      it { is_expected.to be_a NArray }

      it 'has size of the 2nd param' do
        expect(subject.size).to eq(2)
      end

      it 'has 1D shape with size of the 2nd param' do
        expect(subject.shape).to eq([2])
      end
    end

    context '2 narray_args and known GDAL data_type' do
      subject { GDAL._narray_from_data_type(:GDT_Byte, 2, 3) }
      it { is_expected.to be_a NArray }

      it 'has size of the 2nd param * 3rd param' do
        expect(subject.size).to eq(6)
      end

      it 'has 2D shape with size of each of the params' do
        expect(subject.shape).to eq([2, 3])
      end
    end

    context 'unknown GDAL data_type' do
      it 'raises a GDAL::InvalidDataType exception' do
        expect { GDAL._narray_from_data_type(:bobo) }
          .to raise_exception(GDAL::InvalidDataType)
      end
    end
  end
end
