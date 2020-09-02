# typed: false
# frozen_string_literal: true

module GDAL
  module ColorTableTypes
    module HLS
      def hues
        color_entries_for(1)
      end

      def lightnesses
        color_entries_for(2)
      end

      def saturations
        color_entries_for(3)
      end

      def to_a
        NMatrix[hues, lightnesses, saturations].transpose.to_a
      end
    end
  end
end
