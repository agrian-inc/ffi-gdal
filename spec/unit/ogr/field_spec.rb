# typed: false
# frozen_string_literal: true

require 'ogr/field'

RSpec.describe OGR::Field do
  describe '#integer' do
    context 'not set' do
      it 'returns 0.0' do
        expect(subject.integer).to eql 0
      end
    end
  end

  describe '#integer= + #integer' do
    context 'valid int' do
      it 'sets the value' do
        subject.integer = 1
        expect(subject.integer).to eq 1
      end
    end
  end

  describe '#integer64' do
    context 'not set' do
      it 'returns 0.0' do
        expect(subject.integer64).to eql 0
      end
    end
  end

  describe '#integer64= + #integer64' do
    context 'valid int64' do
      it 'sets the value' do
        subject.integer64 = 2**32 + 1
        expect(subject.integer64).to eq 2**32 + 1
      end
    end
  end

  describe '#real' do
    context 'not set' do
      it 'returns 0.0' do
        expect(subject.real).to eql 0.0
      end
    end
  end

  describe '#real= + #real' do
    context 'valid float' do
      it 'sets the value' do
        subject.real = 1.23
        expect(subject.real).to eq 1.23
      end
    end
  end

  describe '#string' do
    context 'not set' do
      it 'returns an empty string' do
        expect(subject.string).to eq ''
      end
    end
  end

  describe '#string= + #string' do
    context 'valid string' do
      it 'sets the value' do
        subject.string = 'meow'
        expect(subject.string).to eq 'meow'
      end
    end
  end

  describe '#integer_list' do
    context 'not set' do
      it 'returns an empty array' do
        expect(subject.integer_list).to eq []
      end
    end
  end

  describe '#integer_list= + #integer_list' do
    context 'valid int array' do
      it 'sets the value' do
        subject.integer_list = [1, 2]
        expect(subject.integer_list).to eq [1, 2]
      end
    end
  end

  describe '#integer64_list' do
    context 'not set' do
      it 'returns an empty array' do
        expect(subject.integer64_list).to eq []
      end
    end
  end

  describe '#integer64_list= + #integer64_list' do
    context 'valid int64 array' do
      it 'sets the value' do
        subject.integer64_list = [2**32 + 1, 2**32 + 2]
        expect(subject.integer64_list).to eq [2**32 + 1, 2**32 + 2]
      end
    end
  end

  describe '#real_list' do
    context 'not set' do
      it 'returns an empty array' do
        expect(subject.real_list).to eq []
      end
    end
  end

  describe '#real_list= + #real_list' do
    context 'valid float array' do
      it 'sets the value' do
        subject.real_list = [1.5, 6.9]
        expect(subject.real_list).to eq [1.5, 6.9]
      end
    end
  end

  describe '#string_list' do
    context 'not set' do
      it 'returns an empty array' do
        expect(subject.string_list).to eq []
      end
    end
  end

  describe '#string_list= + #string_list' do
    context 'valid string array' do
      it 'sets the value' do
        subject.string_list = %w[one two]
        expect(subject.string_list).to eq %w[one two]
      end
    end
  end

  describe '#binary' do
    context 'not set' do
      it 'returns an empty string' do
        expect(subject.binary).to eq ''
      end
    end
  end

  describe '#binary= + #binary' do
    context 'valid binary' do
      it 'sets the value' do
        subject.binary = [1, 2, 3].pack('C*')
        expect(subject.binary).to eq [1, 2, 3].pack('C*')
      end
    end
  end

  describe '#set' do
    context 'not set' do
      it 'returns a Hash with markers set to 0' do
        expect(subject.set).to eq(marker1: 0, marker2: 0)
      end
    end
  end

  describe '#set= + #set' do
    context 'valid set hash' do
      it 'sets the value' do
        subject.set = { marker1: 1, marker2: 200 }
        expect(subject.set).to eq(marker1: 1.0, marker2: 200)
      end
    end
  end

  describe '#date' do
    context 'not set' do
      it 'returns nil' do
        expect(subject.date).to be_nil
      end
    end
  end

  describe '#date= + #date' do
    context 'valid date' do
      let(:now) { DateTime.now }

      it 'sets the date' do
        subject.date = now
        expect(subject.date.httpdate).to eq now.httpdate
      end
    end
  end
end
