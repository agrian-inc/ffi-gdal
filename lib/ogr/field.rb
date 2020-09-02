# typed: false
# frozen_string_literal: true

require 'date'
require_relative '../ogr'
require_relative '../gdal'

module OGR
  class Field
    # @return [FFI::OGR::Point]
    attr_reader :c_struct

    # @param ogr_field_struct [FFI::OGR::Point, FFI::Pointer]
    def initialize(ogr_field_struct = nil)
      @c_struct = ogr_field_struct || ::FFI::OGR::Field.new
    end

    # @return [FFI::Pointer]
    def c_pointer
      @c_struct.to_ptr
    end

    # @return [Integer]
    def integer
      @c_struct[:integer]
    end
    alias to_i integer

    # @param new_int [Integer]
    def integer=(new_int)
      @c_struct[:integer] = new_int
    end

    # @return [Integer]
    def integer64
      @c_struct[:integer64]
    end

    # @param new_int64 [Integer]
    def integer64=(new_int64)
      @c_struct[:integer64] = new_int64
    end

    # @return [Float]
    def real
      @c_struct[:real]
    end
    alias to_f real

    # @param new_real [Float]
    def real=(new_real)
      @c_struct[:real] = new_real
    end

    # TODO: This blows up when another value type has been set.
    def string
      return '' if @c_struct[:string]&.null?

      @c_struct[:string].read_string
    end

    def string=(new_string)
      @c_struct[:string] = FFI::MemoryPointer.from_string(new_string)
    end

    # @return [Array<Integer>]
    def integer_list
      il = @c_struct[:integer_list]
      return [] if il[:count].zero?

      il[:list].read_array_of_int(il[:count])
    end

    # @param new_integer_list [Array<Integer>]
    def integer_list=(new_integer_list)
      list_ptr = FFI::MemoryPointer.new(:int, new_integer_list.length)
      list_ptr.write_array_of_int(new_integer_list)

      il = FFI::OGR::FieldTypes::IntegerList.new
      il[:count] = new_integer_list.size
      il[:list] = list_ptr

      @c_struct[:integer_list] = il
    end

    # @return [Array<Integer>]
    def integer64_list
      il = @c_struct[:integer_list]
      return [] if il[:count].zero?

      il[:list].read_array_of_int64(il[:count])
    end
    alias to_bignum integer64_list

    # @param new_integer64_list [Array<Integer>]
    def integer64_list=(new_integer64_list)
      list_ptr = FFI::MemoryPointer.new(:int64, new_integer64_list.size)
      list_ptr.write_array_of_int64(new_integer64_list)

      il = FFI::OGR::FieldTypes::Integer64List.new
      il[:count] = new_integer64_list.size
      il[:list] = list_ptr

      @c_struct[:integer64_list] = il
    end
    alias bignum_list= integer64_list=

    # @return [Array<Float>]
    def real_list
      rl = @c_struct[:real_list]
      return [] if rl[:count].zero?

      rl[:list].read_array_of_double(rl[:count])
    end
    alias float_list real_list

    # @param new_real_list [Array<Float>]
    def real_list=(new_real_list)
      list_ptr = FFI::MemoryPointer.new(:double, new_real_list.size)
      list_ptr.write_array_of_double(new_real_list)

      rl = FFI::OGR::FieldTypes::RealList.new
      rl[:count] = new_real_list.size
      rl[:list] = list_ptr

      @c_struct[:real_list] = rl
    end
    alias float_list= real_list=

    # @return [Array<String>]
    def string_list
      sl = @c_struct[:string_list]
      return [] if sl[:count].zero?

      sl[:list].read_array_of_pointer(sl[:count]).map(&:read_string)
    end

    # @param new_string_list [Array<String>]
    def string_list=(new_string_list)
      list_ptr = GDAL._string_array_to_pointer(new_string_list)

      sl = FFI::OGR::FieldTypes::StringList.new
      sl[:count] = new_string_list.size
      sl[:list] = list_ptr

      @c_struct[:string_list] = sl
    end

    # @return [String] 8-bit, unsigned data (uchar). Unpack with
    #   String#unpack('C*').
    def binary
      b = @c_struct[:binary]

      b[:count].positive? ? b[:data].read_bytes(b[:count]) : ''
    end

    # @param new_binary [String] Binary string of 8-bit, unsigned data (uchar).
    #   Pack with Array#pack('C*').
    def binary=(new_binary)
      data = FFI::MemoryPointer.new(:uchar, new_binary.length)
      data.put_bytes(0, new_binary)

      b = FFI::OGR::FieldTypes::Binary.new
      b[:data] = data
      b[:count] = new_binary.length

      @c_struct[:binary] = b
    end

    # @return [Hash]
    def set
      { marker1: @c_struct[:set][:marker1], marker2: @c_struct[:set][:marker2] }
    end

    # @param new_set [Hash{marker1 => Integer, marker2 => Integer}]
    def set=(new_set)
      set = FFI::OGR::FieldTypes::Set.new
      set[:marker1] = new_set[:marker1]
      set[:marker2] = new_set[:marker2]

      @c_struct[:set] = set
    end

    # @return [DateTime]
    def date
      c_date = @c_struct[:date]
      return if c_date[:year].zero? || c_date[:month].zero? || c_date[:day].zero?

      formatted_tz = OGR._format_time_zone_for_ruby(c_date[:tz_flag].to_i)
      DateTime.new(c_date[:year],
                   c_date[:month],
                   c_date[:day],
                   c_date[:hour],
                   c_date[:minute],
                   c_date[:second],
                   formatted_tz)
    end

    # @param new_date [Date, Time, DateTime]
    def date=(new_date)
      # All of Date's Time methods are private. Using #send to accomdate Date.
      zone = OGR._format_time_zone_for_ogr(new_date.send(:zone))

      date = FFI::OGR::FieldTypes::Date.new
      date[:year] = new_date.year
      date[:month] = new_date.month
      date[:day] = new_date.day
      date[:hour] = new_date.hour
      date[:minute] = new_date.send(:min)
      date[:second] = new_date.send(:sec) + (new_date.to_time.usec / 1_000_000.to_f)
      date[:tz_flag] = zone

      @c_struct[:date] = date
    end
  end
end
