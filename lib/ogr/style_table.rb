# typed: true
# frozen_string_literal: true

require_relative '../gdal'
require_relative '../ogr'

module OGR
  class StyleTable
    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      return unless pointer && !pointer.null?

      FFI::OGR::API.OGR_STBL_Destroy(pointer)
    end

    # @return [FFI::Pointer] C pointer to the C style table.
    attr_reader :c_pointer

    # @param [FFI::Pointer] c_pointer
    def initialize(c_pointer = nil)
      @c_pointer = if c_pointer
                     c_pointer
                   else
                     pointer = FFI::OGR::API.OGR_STBL_Create
                     pointer.autorelease = false
                     FFI::AutoPointer.new(pointer, StyleTable.method(:release))
                   end

      raise 'Unable to create StyleTable' if @c_pointer.null?
    end

    def destroy!
      StyleTable.release(@c_pointer)

      @c_pointer = nil
    end

    # @param name [String] Name of the style.
    # @param style [String]
    # @return [Boolean]
    def add_style(name, style)
      FFI::OGR::API.OGR_STBL_AddStyle(@c_pointer, name, style)
    end

    # @param style_name [String]
    # @return [String, nil]
    def find(style_name)
      FFI::OGR::API.OGR_STBL_Find(@c_pointer, style_name)
    end

    # @return [String, nil] The style name of the last string fetched with #next_style.
    def last_style_name
      FFI::OGR::API.OGR_STBL_GetLastStyleName(@c_pointer)
    end

    # @return [String, nil] The next style string from the table.
    def next_style
      FFI::OGR::API.OGR_STBL_GetNextStyle(@c_pointer)
    end

    # @param file_name [String]
    # @return [Boolean]
    def load!(file_name)
      FFI::OGR::API.OGR_STBL_LoadStyleTable(@c_pointer, file_name)
    end

    # Resets the #next_style to the 0th style.
    def reset_style_string_reading
      FFI::OGR::API.OGR_STBL_ResetStyleStringReading(@c_pointer)
    end

    # @param file_name [String] Path to the file to save to.
    # @return [Boolean]
    def save(file_name)
      FFI::OGR::API.OGR_STBL_SaveStyleTable(@c_pointer, file_name)
    end
  end
end
