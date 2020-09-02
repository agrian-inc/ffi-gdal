# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module GDAL
    class GridDataMetricsOptions < FFI::Struct
      layout :radius1, :double,
             :radius2, :double,
             :angle, :double,
             :min_points, CPL::Port.find_type(:GUInt32),
             :no_data_value, :double
    end
  end
end
