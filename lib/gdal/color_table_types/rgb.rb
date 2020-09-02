# typed: false
# frozen_string_literal: true

module GDAL
  module ColorTableTypes
    module RGB
      def reds
        color_entries_for(1)
      end

      def greens
        color_entries_for(2)
      end

      def blues
        color_entries_for(3)
      end

      def alphas
        color_entries_for(4)
      end

      def to_a
        NMatrix[reds, greens, blues, alphas].transpose.to_a
      end
    end
  end
end
