# typed: false
# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::Point do
  subject { OGR::Geometry.create_from_wkt(wkt) }
  let(:wkt) { 'POINT (1 2)' }

  let(:another_point) do
    OGR::Geometry.create_from_wkt('POINT (2 3)')
  end

  let(:same_point) do
    OGR::Geometry.create_from_wkt(wkt)
  end

  describe '#dimension' do
    specify { expect(subject.dimension).to be_zero }
  end

  describe '#type' do
    specify { expect(subject.type).to eq :wkbPoint }
  end

  describe '#type_to_name' do
    specify { expect(subject.type_to_name).to eq 'Point' }
  end

  describe '#name' do
    specify { expect(subject.name).to eq 'POINT' }
  end

  context 'non-empty point' do
    describe '#coordinate_dimension' do
      specify { expect(subject.coordinate_dimension).to eq 2 }
    end

    describe '#envelope' do
      it 'returns an OGR::Envelope' do
        expect(subject.envelope).to be_a OGR::Envelope
      end
    end

    describe '#geometry_count' do
      specify { expect(subject.geometry_count).to be_zero }
    end

    describe '#point_count' do
      specify { expect(subject.point_count).to eq 1 }
    end

    describe '#equals?' do
      context 'a point with same coordinates' do
        it 'returns true' do
          expect(subject.equals?(same_point)).to eq true
        end
      end

      context 'a point with difference coordinates' do
        it 'returns false' do
          expect(subject.equals?(another_point)).to eq false
        end
      end
    end

    describe '#intersects?' do
      context 'a point with same coordinates' do
        it 'returns true' do
          expect(subject.intersects?(same_point)).to eq true
        end
      end

      context 'a point with difference coordinates' do
        it 'returns false' do
          expect(subject.intersects?(another_point)).to eq false
        end
      end
    end

    describe '#disjoint?' do
      context 'a point with same coordinates' do
        it 'returns false' do
          expect(subject.disjoint?(same_point)).to eq false
        end
      end

      context 'a point with difference coordinates' do
        it 'returns true' do
          expect(subject.disjoint?(another_point)).to eq true
        end
      end
    end

    describe '#touches?' do
      context 'a point with same coordinates' do
        # Not sure why this returns false...
        it 'returns false' do
          expect(subject.touches?(same_point)).to eq false
        end
      end

      context 'a point with difference coordinates' do
        it 'returns false' do
          expect(subject.touches?(another_point)).to eq false
        end
      end
    end

    describe '#crosses?' do
      context 'a point with same coordinates' do
        it 'returns false' do
          expect(subject.crosses?(same_point)).to eq false
        end
      end

      context 'a point with difference coordinates' do
        it 'returns false' do
          expect(subject.crosses?(another_point)).to eq false
        end
      end
    end

    describe '#within?' do
      context 'a point with same coordinates' do
        it 'returns true' do
          expect(subject.within?(same_point)).to eq true
        end
      end

      context 'a point with difference coordinates' do
        it 'returns false' do
          expect(subject.within?(another_point)).to eq false
        end
      end
    end

    describe '#contains?' do
      context 'a point with same coordinates' do
        it 'returns true' do
          expect(subject.contains?(same_point)).to eq true
        end
      end

      context 'a point with difference coordinates' do
        it 'returns false' do
          expect(subject.contains?(another_point)).to eq false
        end
      end
    end

    describe '#overlaps?' do
      context 'a point with same coordinates' do
        it 'returns false' do
          expect(subject.overlaps?(same_point)).to eq false
        end
      end

      context 'a point with difference coordinates' do
        it 'returns false' do
          expect(subject.overlaps?(another_point)).to eq false
        end
      end
    end

    describe '#empty?' do
      it 'returns false' do
        expect(subject.empty?).to eq false
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(subject.valid?).to eq true
      end
    end

    describe '#simple?' do
      it 'returns true' do
        expect(subject.simple?).to eq true
      end
    end

    describe '#ring?' do
      it 'returns false' do
        expect(subject.ring?).to eq false
      end
    end

    describe '#polygonize' do
      it 'returns nil' do
        expect(subject.polygonize).to be_nil
      end
    end

    describe '#x' do
      it 'returns the x value' do
        expect(subject.x).to eq 1
      end
    end

    describe '#y' do
      it 'returns the y value' do
        expect(subject.y).to eq 2
      end
    end

    describe '#point_value' do
      it 'returns x & y as an array' do
        expect(subject.point_value).to eq([1.0, 2.0])
      end
    end

    describe '#set_point' do
      it 'changes the x & y values' do
        expect { subject.set_point(5, 6) }.to change { subject.point_value }
          .from([1.0, 2.0]).to([5.0, 6.0])
      end
    end

    describe '#add_point' do
      it 'changes the x & y values' do
        expect { subject.add_point(5, 6) }.to change { subject.point_value }
          .from([1.0, 2.0]).to([5.0, 6.0])
      end
    end

    describe '#empty!' do
      it 'clears the point' do
        expect { subject.empty! }.to change { subject.point_value }
          .from([1.0, 2.0]).to([])
      end
    end
  end

  context 'empty point' do
    let(:wkt) { 'POINT EMPTY' }

    describe '#coordinate_dimension' do
      specify { expect(subject.coordinate_dimension).to eq 2 }
    end

    describe '#geometry_count' do
      specify { expect(subject.geometry_count).to be_zero }
    end

    describe '#point_count' do
      specify { expect(subject.point_count).to be_zero }
    end

    describe '#empty?' do
      it 'returns true' do
        expect(subject.empty?).to eq true
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(subject.valid?).to eq true
      end
    end

    describe '#simple?' do
      it 'returns true' do
        expect(subject.simple?).to eq true
      end
    end

    describe '#x' do
      it 'returns nil' do
        expect(subject.x).to be_nil
      end
    end

    describe '#y' do
      it 'returns nil' do
        expect(subject.x).to be_nil
      end
    end

    describe '#point_value' do
      it 'returns an empty array' do
        expect(subject.point_value).to eq([])
      end
    end

    describe '#set_point' do
      it 'changes the x & y values' do
        expect { subject.set_point(5, 6) }.to change { subject.point_value }
          .from([]).to([5.0, 6.0])
      end
    end

    describe '#add_point' do
      it 'changes the x & y values' do
        expect { subject.add_point(5, 6) }.to change { subject.point_value }
          .from([]).to([5.0, 6.0])
      end
    end

    describe '#envelope' do
      it 'returns an OGR::Envelope' do
        expect(subject.envelope).to be_a OGR::Envelope
      end
    end
  end
end
