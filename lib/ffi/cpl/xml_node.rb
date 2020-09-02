# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module CPL
    class XMLNode < FFI::Struct
      layout :type, FFI::CPL::MiniXML::XMLNodeType,
             :value, :string,
             :next, XMLNode.ptr,
             :child, XMLNode.ptr
    end
  end
end
