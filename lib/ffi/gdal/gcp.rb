# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module GDAL
    # Ground Control Point
    class GCP < FFI::Struct
      layout :id, :string,
             :info, :string,
             :pixel, :double,
             :line, :double,
             :x, :double,
             :y, :double,
             :z, :double
    end
  end
end
