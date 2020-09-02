# typed: false
# frozen_string_literal: true

require 'ogr/error_handling'

RSpec.describe OGR::ErrorHandling do
  describe '.handle_ogr_err' do
    context ':OGRERR_NONE' do
      it 'does not raise' do
        expect { described_class.handle_ogr_err('') { :OGRERR_NONE } }
          .to_not raise_exception
      end
    end

    context ':OGRERR_NOT_ENOUGH_DATA' do
      it 'raises an OGR::NotEnoughData exception' do
        expect { described_class.handle_ogr_err('') { :OGRERR_NOT_ENOUGH_DATA } }
          .to raise_exception OGR::NotEnoughData
      end
    end

    context ':OGRERR_NOT_ENOUGH_MEMORY' do
      it 'raises an NoMemoryError exception' do
        expect { described_class.handle_ogr_err('') { :OGRERR_NOT_ENOUGH_MEMORY } }
          .to raise_exception NoMemoryError
      end
    end

    context ':OGRERR_UNSUPPORTED_GEOMETRY_TYPE' do
      it 'raises an OGR::UnsupportedGeometryType exception' do
        expect { described_class.handle_ogr_err('') { :OGRERR_UNSUPPORTED_GEOMETRY_TYPE } }
          .to raise_exception OGR::UnsupportedGeometryType
      end
    end

    context ':OGRERR_UNSUPPORTED_OPERATION' do
      it 'raises an OGR::UnsupportedOperation exception' do
        expect { described_class.handle_ogr_err('') { :OGRERR_UNSUPPORTED_OPERATION } }
          .to raise_exception OGR::UnsupportedOperation
      end
    end

    context ':OGRERR_CORRUPT_DATA' do
      it 'raises an OGR::CorruptData exception' do
        expect { described_class.handle_ogr_err('') { :OGRERR_CORRUPT_DATA } }
          .to raise_exception OGR::CorruptData
      end
    end

    context ':OGRERR_FAILURE' do
      it 'raises an OGR::Failure exception' do
        expect { described_class.handle_ogr_err('') { :OGRERR_FAILURE } }
          .to raise_exception OGR::Failure
      end
    end

    context ':OGRERR_UNSUPPORTED_SRS' do
      it 'raises an OGR::UnsupportedSRS exception' do
        expect { described_class.handle_ogr_err('') { :OGRERR_UNSUPPORTED_SRS } }
          .to raise_exception OGR::UnsupportedSRS
      end
    end

    context ':OGRERR_INVALID_HANDLE' do
      it 'raises an OGR::InvalidHandle exception' do
        expect { described_class.handle_ogr_err('') { :OGRERR_INVALID_HANDLE } }
          .to raise_exception OGR::InvalidHandle
      end
    end
  end
end
