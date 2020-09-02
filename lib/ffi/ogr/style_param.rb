# typed: strict
# frozen_string_literal: true

require 'ffi'
require_relative '../cpl/port'

module FFI
  module OGR
    class StyleParam < FFI::Struct
      layout :param, :int,
             :token, :string,
             :georef, FFI::CPL::Port.find_type(:GBool),
             :type, FFI::OGR::Featurestyle::SType
    end
  end
end
