# typed: ignore
# frozen_string_literal: true

module OGR
  module GeometryMixins
    module ContainerMixins
      include Enumerable

      # Iterates over each geometry in the container geometry. Per OGR docs, the
      # yielded geometry should not be modified; if you need to do something to
      # that geometry, you should {{#clone}} it. Additionally, the yielded
      # geometry is only valid until the containing changes.
      #
      # @yieldparam [OGR::Geometry]
      # @return [Enumerator]
      # @see http://gdal.org/1.11/ogr/ogr__api_8h.html#a6bac93150529a5c98811db29e289dd66
      def each
        return enum_for(:each) unless block_given?

        geometry_count.times do |i|
          yield geometry_at(i)
        end
      end
    end
  end
end
