# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module GDAL
    class GridNearestNeighborOptions < FFI::Struct
      layout :radius1, :double,
             :radius2, :double,
             :angle, :double,
             :no_data_value, :double
    end
  end
end
