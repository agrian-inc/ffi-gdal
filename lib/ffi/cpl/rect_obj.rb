# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module CPL
    class RectObj < ::FFI::Struct
      layout :min_x, :double,
             :min_y, :double,
             :max_x, :double,
             :max_y, :double
    end
  end
end
