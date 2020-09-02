# typed: false
# frozen_string_literal: true

require 'gdal/version_info'

RSpec.describe GDAL::VersionInfo do
  subject do
    Object.new.extend(described_class)
  end

  describe '#version_num' do
    it 'returns a non-empty String' do
      expect(subject.version_num).to be_a String
      expect(subject.version_num).to_not be_empty
    end
  end

  describe '#release_date' do
    it 'returns a Date' do
      expect(subject.release_date).to be_a Date
    end
  end

  describe '#release_name' do
    it 'returns a non-empty String' do
      expect(subject.release_name).to be_a String
      expect(subject.release_name).to_not be_empty
    end
  end

  describe '#license' do
    it 'returns a non-empty String' do
      expect(subject.license).to be_a String
      expect(subject.license).to_not be_empty
    end
  end

  describe '#build_info' do
    it 'returns a Hash of info' do
      expect(subject.build_info).to be_a Hash
    end
  end

  describe '#long_version' do
    it 'returns a non-empty String' do
      expect(subject.long_version).to be_a String
      expect(subject.long_version).to_not be_empty
    end
  end
end
