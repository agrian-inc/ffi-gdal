# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module CPL
    class MIMEPart < ::FFI::Struct
      layout :headers, :pointer,
             :data, :pointer,
             :data_length, :int
    end
  end
end
