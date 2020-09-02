# typed: strict
# frozen_string_literal: true

require 'ffi'

module FFI
  module GDAL
    class RPCInfo < FFI::Struct
      layout :line_off, :double,
             :samp_off, :double,
             :lat_off, :double,
             :long_off, :double,
             :height_off, :double,
             :line_scale, :double,
             :samp_scale, :double,
             :lat_scale, :double,
             :long_scale, :double,
             :height_scale, :double,
             :line_num_coeff, [:double, 20],
             :line_den_coeff, [:double, 20],
             :samp_num_coeff, [:double, 20],
             :samp_den_coeff, [:double, 20],
             :min_long, :double,
             :min_lat, :double,
             :max_long, :double,
             :max_at, :double
    end
  end
end
