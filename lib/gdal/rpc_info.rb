# typed: true
# frozen_string_literal: true

require 'forwardable'
require_relative '../gdal'

module GDAL
  # @return [FFI::GDAL::RPCInfo]
  attr_reader :c_struct

  # Wrapper for FFI::GDAL::RPCInfo.
  class RPCInfo
    extend Forwardable
    def_delegator :@c_struct, :[]

    # @param struct_or_ptr [FFI::GDAL::RPCInfo, FFI::Pointer]
    def initialize(struct_or_ptr = nil)
      @c_struct = case struct_or_ptr
                  when FFI::GDAL::RPCInfo
                    struct_or_ptr
                  when FFI::Pointer
                    FFI::GDAL::RPCInfo.new(struct_or_ptr)
                  else
                    FFI::GDAL::RPCInfo.new
                  end
    end

    # @return [FFI::Pointer]
    def c_pointer
      @c_struct.to_ptr
    end

    # @return [Array<String>]
    def to_metadata
      FFI::GDAL::Alg.RPCInfoToMD(@c_struct).read_array_of_string(0)
    end
  end
end
