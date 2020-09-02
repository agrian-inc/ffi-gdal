# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module GDAL
    class ColorEntry < FFI::Struct
      layout :c1, :short,
             :c2, :short,
             :c3, :short,
             :c4, :short
    end
  end
end
