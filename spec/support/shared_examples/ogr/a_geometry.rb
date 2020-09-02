# typed: false
# frozen_string_literal: true

RSpec.shared_examples 'a geometry' do
  require 'ogr'

  describe '#coordinate_dimension' do
    subject { geometry.coordinate_dimension }
    it { is_expected.to eq 2 }
  end

  describe '#coordinate_dimension=' do
    context 'valid value' do
      it 'changes the dimension to the new value' do
        skip
      end
    end

    context 'invalid value' do
      it '???' do
        skip
      end
    end
  end

  describe '#empty!' do
    it 'removes all points/geometries from the geometry' do
      skip
    end
  end

  describe '#empty?' do
    context 'when empty' do
      subject { described_class.new }
      it { is_expected.to be_empty }
    end

    context 'when with points' do
      it 'is not empty' do
        skip 'Writing the test'
      end
    end
  end

  describe '#envelope' do
    subject { geometry.envelope }
    it { is_expected.to be_a OGR::Envelope }
  end

  describe '#dump_readable' do
    context 'with prefix' do
      it 'writes out to a file' do
        skip
      end
    end

    context 'without prefix' do
      it 'writes out to a file' do
        skip
      end
    end
  end

  describe '#intersects?' do
    context 'self intersects other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not intersect other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#equals?' do
    context 'self equals other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not equals other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#disjoint?' do
    context 'self disjoints other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not disjoint other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#touches?' do
    context 'self touches other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not touch other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#crosses?' do
    context 'self touches other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not touch other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#within?' do
    context 'self is within other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self is not within other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#contains?' do
    context 'self contains other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not contain other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#overlaps?' do
    context 'self overlaps other geometry' do
      it 'returns true' do
        skip
      end
    end

    context 'self does not overlap other geometry' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#valid?' do
    context 'self is valid' do
      it 'returns true' do
        skip
      end
    end

    context 'self is not valid' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#simple?' do
    context 'self is simple' do
      it 'returns true' do
        skip
      end
    end

    context 'self is not simple' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#ring?' do
    context 'self is a ring' do
      it 'returns true' do
        skip
      end
    end

    context 'self is not a ring' do
      it 'returns false' do
        skip
      end
    end
  end

  describe '#intersection' do
    specify { skip 'Implementation' }
  end

  describe '#union' do
    context 'where there is no union' do
      specify { skip }
    end

    context 'where there is union' do
      specify { skip }
    end
  end

  describe '#close_rings!' do
    it 'adds points to close any potential rings' do
      skip
    end
  end

  describe '#polygonize' do
    it 'adds points to close any potential rings' do
      skip
    end
  end

  describe '#difference' do
    it 'creates a new geometry that represents the difference' do
      skip
    end
  end

  describe '#symmetric_difference' do
    it 'creates a new geometry that represents the difference' do
      skip
    end
  end

  describe '#distance_to' do
    context 'other geometry is nil' do
      it '???' do
        skip
      end
    end

    context 'other geometry is valid' do
      it 'creates a new geometry that represents the difference' do
        skip
      end
    end
  end

  describe '#spatial_reference' do
    context 'none assigned' do
      it 'returns nil' do
        expect(geometry.spatial_reference).to be_nil
      end
    end

    context 'has one assigned' do
      it 'returns a spatial reference' do
        geometry.spatial_reference = OGR::SpatialReference.new_from_epsg 4326
        expect(geometry.spatial_reference).to be_a OGR::SpatialReference
      end
    end
  end

  describe '#spatial_reference=' do
    it 'assigns the new spatial reference' do
      skip
    end
  end

  describe '#transform!' do
    it 'assigns the new spatial reference' do
      skip
    end
  end

  describe '#transform_to!' do
    it 'transforms the points into the new spatial reference' do
      skip
    end

    it 'sets the new spatial reference' do
      skip
    end
  end

  describe '#simplify' do
    context 'preserve_topology is true' do
      it 'returns a new geometry' do
        skip
      end
    end

    context 'preserve_topology is false' do
      it 'returns a new geometry' do
        skip
      end
    end
  end

  describe '#segmentize!' do
    it 'updates the geometry' do
      skip
    end
  end

  describe '#boundary' do
    it 'returns a geometry that represents the boundary of self' do
      skip
    end
  end

  describe '#buffer' do
    it 'returns a new geometry that adds a boundary around self' do
      skip
    end
  end

  describe '#convex_hull' do
    it 'returns a new geometry that is the convex hull of self' do
      skip
    end
  end

  describe '#import_from_wkb' do
    it 'updates self with the new geometry info' do
      skip
    end
  end

  describe '#import_from_wkt' do
    it 'updates self with the new geometry info' do
      skip
    end
  end

  describe '#wkb_size' do
    it 'returns a non-zero integer' do
      expect(geometry.wkb_size).to be_a Integer

      if geometry.name == 'LINEARRING'
        expect(geometry.wkb_size).to be_zero
      else
        expect(geometry.wkb_size).to be_positive
      end
    end
  end

  describe '#to_wkb' do
    it 'returns some binary String data' do
      if geometry.name == 'LINEARRING'
        expect { geometry.to_wkb }.to raise_exception OGR::UnsupportedOperation
      else
        expect(geometry.to_wkb).to be_a String
        expect(geometry.to_wkb).to_not be_empty
      end
    end
  end

  describe '#to_wkt' do
    it 'returns some String data' do
      expect(geometry.to_wkt).to be_a String
      expect(geometry.to_wkt).to_not be_empty
    end
  end

  describe '#to_gml' do
    it 'returns some String data' do
      expect(geometry.to_gml).to be_a String
      expect(geometry.to_gml).to_not be_empty
    end
  end

  describe '#to_kml' do
    it 'returns some String data' do
      expect(geometry.to_kml).to be_a String
      expect(geometry.to_kml).to_not be_empty
    end
  end

  describe '#to_geo_json' do
    it 'returns some String data' do
      expect(geometry.to_geo_json).to be_a String
      expect(geometry.to_geo_json).to_not be_empty
    end
  end
end
