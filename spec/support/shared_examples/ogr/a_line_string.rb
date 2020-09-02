# typed: false
# frozen_string_literal: true

RSpec.shared_examples 'a line string' do
  describe '#dimension' do
    subject { geometry.dimension }
    it { is_expected.to eq 1 }
  end

  describe '#type' do
    subject { geometry.type }
    it { is_expected.to eq :wkbLineString }
  end

  describe '#type_to_name' do
    subject { geometry.type }
    it { is_expected.to eq :wkbLineString }
  end
end
