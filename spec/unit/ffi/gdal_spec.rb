# typed: false
# frozen_string_literal: true

require 'fakefs/safe'

RSpec.describe FFI::GDAL do
  describe '.find_lib' do
    context 'ENV["GDAL_LIBRARY_PATH"] is set' do
      before do
        allow(ENV).to receive(:[]).with('GDAL_LIBRARY_PATH').and_return '/pants'
      end

      it 'returns GDAL_LIBRARY_PATH + libgdal file name' do
        expect(Dir).to receive(:[]).with(%r{/pants/stuff\.+}).and_return '/pants/stuff.dylib'
        expect(described_class.find_lib('stuff')).to match %r{\A/pants/stuff\.+}
      end
    end

    context 'ENV["GDAL_LIBRARY_PATH"] is not set' do
      before do
        allow(described_class).to receive(:search_paths).and_return %w[/pants]
        FakeFS.activate!
        FileUtils.mkdir 'pants'
        FileUtils.touch("/pants/stuff.#{FFI::Platform::LIBSUFFIX}")
      end

      after { FakeFS.deactivate! }

      it 'returns the search path + libgdal file name' do
        expect(described_class.find_lib('stuff')).to match %r{\A/pants/stuff\.+}
      end
    end
  end

  describe '.search_paths' do
    context 'ENV["GDAL_LIBRARY_PATH"] is set' do
      before do
        allow(ENV).to receive(:[]).with('GDAL_LIBRARY_PATH').and_return '/pants'
      end

      it 'returns GDAL_LIBRARY_PATH' do
        expect(described_class.search_paths).to match %r{\A/pants\z}
      end
    end

    context 'ENV["GDAL_LIBRARY_PATH"] is not set' do
      it 'returns a bunch of directories' do
        expect(described_class.search_paths.size).to be_positive
      end
    end
  end

  describe '._files_with_constants' do
    it 'returns a non-empty Array' do
      expect(described_class._files_with_constants).to be_an Array
      expect(described_class._files_with_constants).to_not be_empty
    end
  end

  describe '_file_with_constants' do
    context 'valid file' do
      it 'returns the path to that file' do
        expect(described_class._file_with_constants('gdal.h')).to match '.+gdal\.h\z'
      end
    end

    context 'invalid file' do
      it 'returns nil' do
        expect(described_class._file_with_constants('derp')).to be_nil
      end
    end
  end
end
