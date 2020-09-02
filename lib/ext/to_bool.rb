# typed: true
# frozen_string_literal: true

class Integer
  def to_bool
    return true if self == 1
    return false if zero?

    raise "Integer '#{self}' can't be converted to Boolean."
  end
end

class String
  def to_bool
    return true if to_i == 1
    return false if to_i.zero?

    raise "String '#{self}' can't be converted to Boolean."
  end
end
