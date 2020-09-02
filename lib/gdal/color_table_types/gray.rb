# typed: false
# frozen_string_literal: true

module GDAL
  module ColorTableTypes
    module Gray
      def grays
        color_entries_for(1)
      end
    end
  end
end
