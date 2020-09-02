# typed: false
# frozen_string_literal: true

require 'ogr/style_tool'

RSpec.describe OGR::StyleTool do
  describe '#initialize' do
    context 'with supported classes' do
      let(:supported_classes) do
        %i[OGRSTCPen OGRSTCBrush OGRSTCSymbol OGRSTCLabel]
      end

      it 'does not raise an exception' do
        supported_classes.each do |supported_class|
          expect do
            described_class.new(supported_class)
          end.to_not raise_exception
        end
      end
    end

    context 'with unsupported classes' do
      let(:supported_classes) do
        %i[OGRSTCNone OGRSTCVector]
      end

      it 'raises an exception' do
        supported_classes.each do |supported_class|
          expect do
            described_class.new(supported_class)
          end.to raise_exception OGR::CreateFailure
        end
      end
    end
  end

  subject(:pen_tool) { described_class.new(:OGRSTCPen) }

  describe '#style_string' do
    context 'default style string' do
      subject { pen_tool.style_string }
      it { is_expected.to be_nil }
    end
  end

  describe '#type' do
    it 'returns the type the tool was created with' do
      expect(subject.type).to eq :OGRSTCPen
    end
  end

  describe '#unit' do
    context 'default unit' do
      subject { pen_tool.unit }
      it { is_expected.to eq :OGRSTUMM }
    end
  end

  describe '#unit + #set_unit' do
    context 'valid unit type' do
      it 'sets to the new unit' do
        subject.set_unit :OGRSTUPixel, 13
        expect(subject.unit).to eq :OGRSTUPixel
      end
    end
  end

  describe '#param_as_double + #set_param_as_*' do
    context 'the set value is a string' do
      before { subject.set_param_as_string(0, 'hello') }

      it 'returns 0.0' do
        expect(subject.param_as_double(0)).to eq 0.0
      end
    end

    context 'the set value is an Int' do
      before { subject.set_param_as_number(0, 123) }

      it 'returns the Int as a Float' do
        expect(subject.param_as_double(0)).to eq 123.0
      end
    end

    context 'the set value is a float' do
      before { subject.set_param_as_double(0, 123.123) }

      it 'returns the Float' do
        expect(subject.param_as_double(0)).to eq 123.123
      end
    end
  end

  describe '#param_as_number + #set_param_as_*' do
    context 'the set value is a string' do
      before { subject.set_param_as_string(0, 'hello') }

      it 'returns 0' do
        expect(subject.param_as_number(0)).to eq 0
      end
    end

    context 'the set value is an Int' do
      before { subject.set_param_as_number(0, 123) }

      it 'returns the Int' do
        expect(subject.param_as_number(0)).to eq 123
      end
    end

    context 'the set value is a float' do
      before { subject.set_param_as_double(0, 123.567) }

      it 'returns the Int part of the Float' do
        expect(subject.param_as_number(0)).to eq 123
      end
    end
  end

  describe '#param_as_string + #set_param_as_*' do
    context 'the set value is a string' do
      before { subject.set_param_as_string(0, 'hello') }

      it 'returns the string' do
        expect(subject.param_as_string(0)).to eq 'hello'
      end
    end

    context 'the set value is an Int' do
      before { subject.set_param_as_number(0, 123) }

      it 'returns the Int as a String' do
        expect(subject.param_as_string(0)).to eq '123'
      end
    end

    context 'the set value is a float' do
      before { subject.set_param_as_double(0, 123.567) }

      it 'returns the Float with 6 decimals of precision' do
        expect(subject.param_as_string(0)).to eq '123.567000'
      end
    end
  end

  describe '#rgb_from_string' do
    context 'nil passed in' do
      it 'returns a Hash with all nil values' do
        expect(subject.rgb_from_string(nil)).to eq(red: nil, green: nil, blue: nil, alpha: nil)
      end
    end

    context 'an RGBA color passed in' do
      it do
        expect(subject.rgb_from_string('#123456AB')).to eq(red: 18, green: 52, blue: 86, alpha: 171)
      end
    end
  end
end
