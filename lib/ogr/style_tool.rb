# typed: false
# frozen_string_literal: true

require_relative '../ogr'

module OGR
  class StyleTool
    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      return unless pointer && !pointer.null?

      FFI::OGR::API.OGR_ST_Destroy(pointer)
    end

    # @return [FFI::Pointer] C pointer to the C style tool.
    attr_reader :c_pointer

    # @param style_tool_class [FFI::OGR::Core::STClassId] Must be one of :OGRSTCPen,
    #   :OGRSTCBrush, :OGRSTCSymbol, :OGRSTCLabel.
    def initialize(style_tool_class)
      pointer = FFI::OGR::API.OGR_ST_Create(style_tool_class)

      if !pointer || pointer.null?
        raise OGR::CreateFailure, "Unable to create StyleTool using class #{style_tool_class}"
      end

      @c_pointer = FFI::AutoPointer.new(pointer, StyleTool.method(:release))
    end

    # @return [String, nil]
    def style_string
      style, ptr = FFI::OGR::API.OGR_ST_GetStyleString(@c_pointer)
      ptr.autorelease = false

      style
    end

    # @return [FFI::OGR::Core::STClassId]
    def type
      FFI::OGR::API.OGR_ST_GetType(@c_pointer)
    end

    # @return [FFI::OGR::Core::STUnitId]
    def unit
      FFI::OGR::API.OGR_ST_GetUnit(@c_pointer)
    end

    # @param new_unit [FFI::OGR::Core::STUnitId]
    # @param ground_to_paper_scale [Float]
    def set_unit(new_unit, ground_to_paper_scale)
      FFI::OGR::API.OGR_ST_SetUnit(@c_pointer, new_unit, ground_to_paper_scale)
    end

    # @param param_number [Integer]
    # @return [Float, nil]
    def param_as_double(param_number)
      value_is_null_ptr = FFI::MemoryPointer.new(:int)
      value = FFI::OGR::API.OGR_ST_GetParamDbl(@c_pointer, param_number, value_is_null_ptr)

      value_is_null_ptr.read_int.to_bool ? nil : value
    end
    alias param_as_float param_as_double

    # @param param_number [Integer]
    # @param value [Float]
    def set_param_as_double(param_number, value)
      FFI::OGR::API.OGR_ST_SetParamDbl(@c_pointer, param_number, value)
    end
    alias set_param_as_float set_param_as_double

    # @param param_number [Integer]
    # @return [Integer, nil]
    def param_as_number(param_number)
      value_is_null_ptr = FFI::MemoryPointer.new(:int)
      value = FFI::OGR::API.OGR_ST_GetParamNum(@c_pointer, param_number, value_is_null_ptr)

      value_is_null_ptr.read_int.to_bool ? nil : value
    end
    alias param_as_integer param_as_number

    # @param param_number [Integer]
    # @param value [Integer]
    def set_param_as_number(param_number, value)
      FFI::OGR::API.OGR_ST_SetParamNum(@c_pointer, param_number, value)
    end
    alias set_param_as_integer set_param_as_number

    # @param param_number [Integer]
    # @return [String, nil]
    def param_as_string(param_number)
      value_is_null_ptr = FFI::MemoryPointer.new(:int)
      value, ptr = FFI::OGR::API.OGR_ST_GetParamStr(@c_pointer, param_number, value_is_null_ptr)
      ptr.autorelease = false

      value_is_null_ptr.read_int.to_bool ? nil : value
    end

    # @param param_number [Integer]
    # @param value [String]
    def set_param_as_string(param_number, value)
      FFI::OGR::API.OGR_ST_SetParamStr(@c_pointer, param_number, value)
    end

    # Returns the R, G, B, A components of a #RRGGBB[AA] formatted string.
    #
    # @param color_string [String]
    # @return [Hash{red => Integer, green => Integer, blue => Integer, alpha => Integer}]
    def rgb_from_string(color_string)
      red_ptr = FFI::MemoryPointer.new(:int)
      green_ptr = FFI::MemoryPointer.new(:int)
      blue_ptr = FFI::MemoryPointer.new(:int)
      alpha_ptr = FFI::MemoryPointer.new(:int)

      boolean_result = FFI::OGR::API.OGR_ST_GetRGBFromString(@c_pointer,
                                                             color_string, red_ptr, green_ptr, blue_ptr, alpha_ptr)

      if boolean_result
        {
          red: red_ptr.read_int,
          green: green_ptr.read_int,
          blue: blue_ptr.read_int,
          alpha: alpha_ptr.read_int
        }
      else
        { red: nil, green: nil, blue: nil, alpha: nil }
      end
    end
  end
end
