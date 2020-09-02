# typed: true
# frozen_string_literal: true

module OGR
  module SpatialReferenceMixins
    module Morphers
      # Converts, in place, to ESRI WKT format.
      #
      # @return [OGR::SpatialReference] If successful, returns self.
      # @raise [OGR::Failure]
      def morph_to_esri!
        OGR::ErrorHandling.handle_ogr_err('Unable to morph self to ESRI') do
          FFI::OGR::SRSAPI.OSRMorphToESRI(@c_pointer)
        end

        self
      end

      # Converts, in place, from ESRI WKT format.
      #
      # @return [OGR::SpatialReference] If successful, returns self.
      # @raise [OGR::Failure]
      def morph_from_esri!
        OGR::ErrorHandling.handle_ogr_err('Unable to morph self from ESRI') do
          FFI::OGR::SRSAPI.OSRMorphFromESRI(@c_pointer)
        end

        self
      end
    end
  end
end
