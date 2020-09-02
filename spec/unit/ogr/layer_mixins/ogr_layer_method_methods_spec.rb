# typed: false
# frozen_string_literal: true

require 'ogr/layer'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

  describe '#symmetrical_difference' do
    let(:other_layer) do
      data_source.create_layer 'other layer',
                               geometry_type: :wkbMultiPoint,
                               spatial_reference: OGR::SpatialReference.new_from_epsg(4326)
    end

    it 'does not die' do
      skip 'Figuring out how to init a result pointer'
      # expect { subject.symmetrical_difference(other_layer) }.
      #   to_not raise_exception
    end
  end
end
