# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module OGR
    class ContourWriterInfo < FFI::Struct
      layout :layer, :pointer,
             :geo_transform, [:double, 6],
             :elev_field, :int,
             :id_field, :int,
             :next_id, :int
    end
  end
end
