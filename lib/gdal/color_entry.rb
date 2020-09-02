# typed: true
# frozen_string_literal: true

require_relative 'color_entry_mixins/extensions'

module GDAL
  class ColorEntry
    include ColorEntryMixins::Extensions

    # @return [FFI::GDAL::ColorEntry]
    attr_reader :c_struct

    # @param color_entry [FFI::GDAL::ColorEntry]
    def initialize(color_entry = nil)
      @c_struct = color_entry || FFI::GDAL::ColorEntry.new
    end

    # @return [FFI::Pointer] Pointer to the C struct.
    def c_pointer
      @c_struct.pointer
    end

    def color1
      @c_struct[:c1]
    end

    def color1=(new_color)
      @c_struct[:c1] = new_color
    end

    def color2
      @c_struct[:c2]
    end

    def color2=(new_color)
      @c_struct[:c2] = new_color
    end

    def color3
      @c_struct[:c3]
    end

    def color3=(new_color)
      @c_struct[:c3] = new_color
    end

    def color4
      @c_struct[:c4]
    end

    def color4=(new_color)
      @c_struct[:c4] = new_color
    end
  end
end
