# typed: false
# frozen_string_literal: true

require 'ogr/layer'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

  describe '#geometry_column' do
    it 'returns a String' do
      expect(subject.geometry_column).to be_a String
    end
  end
end
