# typed: false
# frozen_string_literal: true

module GDAL
  module ColorTableTypes
    module CMYK
      def cyans
        color_entries_for(1)
      end

      def magentas
        color_entries_for(2)
      end

      def yellows
        color_entries_for(3)
      end

      def blacks
        color_entries_for(4)
      end

      def to_a
        NMatrix[cyans, magentas, yellows, blacks].transpose.to_a
      end
    end
  end
end
