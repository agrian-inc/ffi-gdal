# typed: true
# frozen_string_literal: true

require_relative 'color_entry_mixins/extensions'
require 'sorbet-runtime'

module GDAL
  class ColorEntry
    extend T::Sig
    include ColorEntryMixins::Extensions

    # @return [FFI::GDAL::ColorEntry]
    attr_reader :c_struct

    # @param color_entry [FFI::GDAL::ColorEntry]
    sig { params(color_entry: T.nilable(FFI::GDAL::ColorEntry)).void }
    def initialize(color_entry = nil)
      @c_struct = color_entry || FFI::GDAL::ColorEntry.new
    end

    # @return [FFI::Pointer] Pointer to the C struct.
    sig { returns(FFI::Pointer) }
    def c_pointer
      @c_struct.pointer
    end

    sig { returns(Integer) }
    def color1
      @c_struct[:c1]
    end

    sig { params(new_color: Integer).void }
    def color1=(new_color)
      @c_struct[:c1] = new_color
    end

    sig { returns(Integer) }
    def color2
      @c_struct[:c2]
    end

    sig { params(new_color: Integer).void }
    def color2=(new_color)
      @c_struct[:c2] = new_color
    end

    sig { returns(Integer) }
    def color3
      @c_struct[:c3]
    end

    sig { params(new_color: Integer).void }
    def color3=(new_color)
      @c_struct[:c3] = new_color
    end

    sig { returns(Integer) }
    def color4
      @c_struct[:c4]
    end

    sig { params(new_color: Integer).void }
    def color4=(new_color)
      @c_struct[:c4] = new_color
    end
  end
end
