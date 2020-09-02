# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module GDAL
    class GridInverseDistanceToAPowerOptions < FFI::Struct
      layout :power, :double,
             :smoothing, :double,
             :anisotropy_ratio, :double,
             :anisotropy_angle, :double,
             :radius1, :double,
             :radius2, :double,
             :angle, :double,
             :max_points, CPL::Port.find_type(:GUInt32),
             :min_points, CPL::Port.find_type(:GUInt32),
             :no_data_value, :double
    end
  end
end
