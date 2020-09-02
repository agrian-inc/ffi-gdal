# typed: false
# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  subject(:wgs84) { OGR::SpatialReference.new_from_epsg(3857) }
  let(:empty_subject) { OGR::SpatialReference.new }

  describe '#set_local_cs' do
    it 'sets the LOCAL_CS' do
      empty_subject.set_local_cs('darrel')
      expect(empty_subject.to_wkt).to start_with 'LOCAL_CS["darrel"'
    end
  end

  describe '#set_proj_cs' do
    it 'sets the PROJCS' do
      empty_subject.set_proj_cs('darrel')
      expect(empty_subject.to_wkt).to start_with 'PROJCS["darrel"'
    end
  end

  describe '#set_geoc_cs' do
    it 'sets the GEOCCS' do
      empty_subject.set_geoc_cs('darrel')
      expect(empty_subject.to_wkt).to start_with 'GEOCCS["darrel"'
    end
  end

  describe '#set_from_user_input' do
    context 'valid input' do
      it 'sets the GEOCCS' do
        empty_subject.set_from_user_input('EPSG:3857')
        expect(empty_subject.to_wkt).to start_with 'PROJCS["WGS 84'
      end
    end

    context 'invalid input' do
      it 'sets the GEOCCS' do
        expect do
          empty_subject.set_from_user_input('darrel')
        end.to raise_exception OGR::CorruptData
      end
    end
  end

  describe '#set_towgs84 + #towgs84' do
    subject do
      s = OGR::SpatialReference.new_from_epsg(4326)
      s.set_towgs84(x_distance: 10, y_distance: 10, x_rotation: 1235.4, scaling_factor: 3)
      s
    end

    it 'returns an Array of 7 floats' do
      expect(subject.towgs84).to eq [10.0, 10.0, 0.0, 1235.4, 0.0, 0.0, 3.0]
    end
  end

  describe '#authority_code' do
    it 'returns the authority code' do
      expect(subject.authority_code).to eq '3857'
    end
  end

  describe '#authority_name' do
    it 'returns the authority name' do
      expect(subject.authority_name).to eq 'EPSG'
    end
  end

  describe '#set_projection' do
    it "doesn't blow up" do
      subject.set_projection 'Transverse_Mercator'
    end
  end

  describe '#set_utm + #utm_zone' do
    it 'sets and gets the UTM zone' do
      subject.set_utm(10)
      expect(subject.utm_zone).to eq 10
    end
  end

  describe '#axis' do
    it 'returns the axis info' do
      expect(subject.axis(0, 'PROJCS')).to eq(name: 'Easting', orientation: :OAO_East)
        .or(eq(name: 'X', orientation: :OAO_East))
    end
  end
end
