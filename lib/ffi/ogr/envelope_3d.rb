# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module OGR
    class Envelope3D < FFI::Struct
      layout :min_x, :double,
             :max_x, :double,
             :min_y, :double,
             :max_y, :double,
             :min_z, :double,
             :max_z, :double
    end
  end
end
