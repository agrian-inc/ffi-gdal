# typed: false
# frozen_string_literal: true

require 'json'

module GDAL
  module ColorTableMixins
    module Extensions
      def color_entries_for(color_number)
        raise "Invalid ColorEntry number 'color#{color_number}'" unless (1..4).to_a.include? color_number

        Array.new(color_entry_count) do |i|
          color_entry(i).send("color#{color_number}".to_sym)
        end
      end

      # @return [Array<GDAL::ColorEntry>]
      def color_entries
        Array.new(color_entry_count) do |i|
          color_entry(i)
        end
      end

      # Does the same as #color_entries, but calls #color_entry_as_rgb() instead
      # of #color_entry().
      #
      # @return [Array<GDAL::ColorEntry>]
      def color_entries_as_rgb
        Array.new(color_entry_count) do |i|
          color_entry_as_rgb(i)
        end
      end
    end
  end
end
