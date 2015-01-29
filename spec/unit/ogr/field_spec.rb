require 'spec_helper'

RSpec.describe OGR::Field do
  describe '.create' do
    it 'creates a new OGR::Field' do
      expect(described_class.create('test', :OFTInteger)).to be_a OGR::Field
    end
  end

  subject(:field) { described_class.create('test field', :OFTInteger) }

  describe '#set' do
    before do
      subject.set('new name', :OFTString, 5, 2, :OJRight)
    end

    it 'sets the name' do
      expect(subject.name).to eq 'new name'
    end

    it 'sets the width' do
      expect(subject.width).to eq 5
    end

    it 'sets the precision' do
      expect(subject.precision).to eq 2
    end

    it 'sets the justification' do
      expect(subject.justification).to eq :OJRight
    end
  end

  describe '#name' do
    it 'returns the name given during creation' do
      expect(subject.name).to eq 'test field'
    end
  end

  describe '#name= + #name' do
    it 'assigns the name' do
      subject.name = 'new test name'
      expect(subject.name).to eq 'new test name'
    end
  end

  describe '#justification' do
    context 'default' do
      it 'returns :OJUndefined' do
        expect(subject.justification).to eq :OJUndefined
      end
    end
  end

  describe '#justification= + #justification' do
    it 'assigns the justification' do
      subject.justification = :OJLeft
      expect(subject.justification).to eq :OJLeft
    end
  end

  describe '#precision' do
    context 'default' do
      it 'returns 0' do
        expect(subject.precision).to be_zero
      end
    end
  end

  describe '#precision= + #precision' do
    it 'assigns the precision' do
      subject.precision = 1
      expect(subject.precision).to eq 1
    end
  end

  describe '#type' do
    context 'default' do
      it 'returns the value it was created with' do
        expect(subject.type).to eq :OFTInteger
      end
    end
  end

  describe '#type= + #type' do
    it 'assigns the type' do
      subject.type = :OFTString
      expect(subject.type).to eq :OFTString
    end
  end

  describe '#width' do
    context 'default' do
      it 'returns 0' do
        expect(subject.width).to be_zero
      end
    end
  end

  describe '#width= + #width' do
    it 'assigns the width' do
      subject.width = 1
      expect(subject.width).to eq 1
    end
  end

  describe '#ignored?' do
    context 'default' do
      it 'returns false' do
        expect(subject).to_not be_ignored
      end
    end
  end

  describe '#ignore= + #ignored?' do
    it 'assigns the value' do
      subject.ignore = true
      expect(subject).to be_ignored
    end
  end

  describe '#as_json' do
    it 'returns a Hash of attributes' do
      expect(subject.as_json).to eq(
        is_ignored: false,
        justification: :OJUndefined,
        name: 'test field',
        precision: 0,
        type: :OFTInteger,
        width: 0
      )
    end
  end

  describe '#to_json' do
    it 'returns a string' do
      expect(subject.to_json).to be_a String
    end
  end
end
