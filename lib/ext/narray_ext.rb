# typed: true
# frozen_string_literal: true

require 'narray'

class NArray
  def type
    case typecode
    when 1 then :byte
    when 2 then :sint
    when 3 then :int
    when 4 then :sfloat
    when 5 then :float
    when 6 then :scomplex
    when 7 then :complex
    when 8 then :object
    else
      raise "Unknown typecode: #{typecode}"
    end
  end
end
