# typed: false
# frozen_string_literal: true

RSpec.shared_examples 'a major object' do
  describe '#metadata_domain_list' do
    it 'is an Array of Strings' do
      expect(subject.metadata_domain_list).to be_an Array

      subject.metadata_domain_list.each do |mdl|
        expect(mdl).to be_a String
      end
    end
  end

  describe '#metadata' do
    context 'default domain' do
      it 'is a Hash' do
        expect(subject.metadata).to be_a Hash
      end
    end
  end

  describe '#metadata_item' do
    context 'default domain' do
      context 'first item in metadata list' do
        it 'is a String' do
          unless subject.metadata.empty?
            key = subject.metadata.keys.first

            expect(subject.metadata_item(key)).to be_a String
          end
        end
      end
    end
  end

  describe '#all_metadata' do
    it 'is a Hash' do
      expect(subject.all_metadata).to be_a Hash
    end

    it 'has a DEFAULT key' do
      expect(subject.all_metadata[:DEFAULT]).to eq subject.metadata
    end
  end

  describe '#description' do
    it 'is a String' do
      expect(subject.description).to be_a String
    end
  end

  describe '#null?' do
    it { is_expected.to_not be_null }
  end
end
