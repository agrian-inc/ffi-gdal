# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module OGR
    class Envelope < FFI::Struct
      layout :min_x, :double,
             :max_x, :double,
             :min_y, :double,
             :max_y, :double
    end
  end
end
