# typed: false
# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::MultiPoint do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end

  it_behaves_like 'a container geometry' do
    let(:child_geometry) { OGR::Point.new }
    let(:edge_geometry1) { OGR::Point.new }
    let(:edge_geometry2) { OGR::Point.new }
  end
end
