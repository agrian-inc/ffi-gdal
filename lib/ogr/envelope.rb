# typed: true
# frozen_string_literal: true

require_relative '../ogr'

module OGR
  class Envelope
    # @return [FFI::OGR::Envelope, FFI::OGR::Envelope3D] The C struct that this
    #   object wraps.
    attr_reader :c_struct

    # @param envelope_struct [FFI::OGR::Envelope]
    def initialize(envelope_struct = nil, three_d: false)
      @c_struct = envelope_struct
      @c_struct ||= three_d ? FFI::OGR::Envelope3D.new : FFI::OGR::Envelope.new
    end

    # @return [FFI::Pointer] Pointer to the C struct.
    def c_pointer
      @c_struct.to_ptr
    end

    # @return [Float]
    def x_min
      @c_struct[:min_x]
    end

    # @param new_x_min [Float]
    def x_min=(new_x_min)
      @c_struct[:min_x] = new_x_min
    end

    # @return [Float]
    def x_max
      @c_struct[:max_x]
    end

    # @param new_x_max [Float]
    def x_max=(new_x_max)
      @c_struct[:max_x] = new_x_max
    end

    # @return [Float]
    def y_min
      @c_struct[:min_y]
    end

    # @param new_y_min [Float]
    def y_min=(new_y_min)
      @c_struct[:min_y] = new_y_min
    end

    # @return [Float]
    def y_max
      @c_struct[:max_y]
    end

    # @param new_y_max [Float]
    def y_max=(new_y_max)
      @c_struct[:max_y] = new_y_max
    end

    # @return [Float, nil]
    def z_min
      return nil unless @c_struct.is_a? FFI::OGR::Envelope3D

      @c_struct[:min_z]
    end

    # @param new_z_min [Float]
    def z_min=(new_z_min)
      return unless @c_struct.is_a? FFI::OGR::Envelope3D

      @c_struct[:min_z] = new_z_min
    end

    # @return [Float, nil]
    def z_max
      return nil unless @c_struct.is_a? FFI::OGR::Envelope3D

      @c_struct[:max_z]
    end

    # @param new_z_max [Float]
    def z_max=(new_z_max)
      return unless @c_struct.is_a? FFI::OGR::Envelope3D

      @c_struct[:max_z] = new_z_max
    end
  end
end
