# typed: false
# frozen_string_literal: true

require 'json'

module GDAL
  module ColorEntryMixins
    module Extensions
      # @param include_fourth [Boolean] Turn off in case you don't want the fourth
      #   color in the array.
      # @return [Array]
      def to_a(include_fourth: true)
        if include_fourth
          [color1, color2, color3, color4]
        else
          [color1, color2, color3]
        end
      end
    end
  end
end
