# typed: false
# frozen_string_literal: true

RSpec.shared_context 'OGR::Layer, spatial_reference' do
  require 'ogr/driver'
  require 'ogr/spatial_reference'

  let(:driver) { OGR::Driver.by_name 'Memory' }
  let(:data_source) { driver.create_data_source 'spec data source' }

  subject(:layer) do
    data_source.create_layer 'spec layer',
                             geometry_type: :wkbMultiPoint,
                             spatial_reference: OGR::SpatialReference.new_from_epsg(4326)
  end
end

RSpec.shared_context 'OGR::Layer, no spatial_reference' do
  require 'ogr/driver'
  require 'ogr/spatial_reference'

  let(:driver) { OGR::Driver.by_name 'Memory' }
  let(:data_source) { driver.create_data_source 'spec data source' }

  subject(:layer) do
    data_source.create_layer 'spec layer',
                             geometry_type: :wkbMultiPoint
  end
end
