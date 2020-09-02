# typed: false
# frozen_string_literal: true

require 'ffi-gdal'

RSpec.describe FFI do
  describe 'autoload CPL' do
    it 'can call CPL functions' do
      expect { FFI::CPL }.to_not raise_exception
    end
  end

  describe 'autoload GDAL' do
    it 'can call GDAL functions' do
      expect { FFI::GDAL }.to_not raise_exception
    end
  end

  describe 'autoload OGR' do
    it 'can call OGR functions' do
      expect { FFI::OGR }.to_not raise_exception
    end
  end
end
