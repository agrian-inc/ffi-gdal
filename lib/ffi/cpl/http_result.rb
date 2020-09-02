# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative 'mime_part'

module FFI
  module CPL
    class HTTPResult < ::FFI::Struct
      layout :status, :int,
             :content_type, :string,
             :error_buffer, :string,
             :data_length, :int,
             :data_alloc, :int,
             :data, :pointer,
             :headers, :pointer,
             :mime_part_count, :int,
             :mime_part, MIMEPart.ptr
    end
  end
end
