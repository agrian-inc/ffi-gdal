# typed: false
# frozen_string_literal: true

module NumericAsDataType
  # @param data_type [FFI::GDAL::GDAL::DataType]
  def to_data_type(data_type)
    case data_type
    when :GDT_Byte, :GDT_UInt16, :GDT_Int16, :GDT_UInt32, :GDT_Int32
      to_i
    when :GDT_Float32, :GDT_Float64
      to_f
    when :GDT_CInt16, :GDT_CInt32, :GDT_CFloat32, :GDT_CFloat64
      to_c
    else
      self
    end
  end
end

class Numeric
  include NumericAsDataType
end
