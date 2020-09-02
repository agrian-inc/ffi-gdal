# typed: strict
# frozen_string_literal: true

require 'log_switch'

module GDAL
  module Logger
    include LogSwitch
  end
end
