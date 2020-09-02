# typed: false
# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::LineString do
  let(:open_line_string) do
    g = described_class.new
    g.add_point(0, 0)
    g.add_point(0, 10)
    g.add_point(10, 10)

    g
  end

  let(:closed_line_string) do
    g = described_class.new
    g.add_point(0, 0)
    g.add_point(0, 10)
    g.add_point(10, 10)
    g.add_point(10, 0)
    g.add_point(0, 0)

    g
  end

  it_behaves_like 'a geometry' do
    let(:geometry) { open_line_string }
  end

  it_behaves_like 'a line string' do
    let(:geometry) { open_line_string }
  end

  describe '#name' do
    subject { open_line_string.name }
    it { is_expected.to eq 'LINESTRING' }
  end

  describe '#point_count' do
    subject { open_line_string.point_count }
    it { is_expected.to eq 3 }
  end

  describe '#intersects?' do
    context 'other geometry is a point' do
      context 'inside the ring' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('POINT (0 1)')
        end

        subject { open_line_string.intersects?(other_geometry) }
        it { is_expected.to eq true }
      end

      context 'on a vertex of the ring' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('POINT (0 0)')
        end

        subject { open_line_string.intersects?(other_geometry) }
        it { is_expected.to eq true }
      end
    end

    context 'other geometry is a line string' do
      context 'outside the ring' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('LINESTRING (100 100, 20 20)')
        end

        subject { open_line_string.intersects?(other_geometry) }
        it { is_expected.to eq false }
      end

      context 'ends on a vertex' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('LINESTRING (50 50, 0 0)')
        end

        subject { open_line_string.intersects?(other_geometry) }
        it { is_expected.to eq true }
      end

      context 'passes across the boundary' do
        let(:other_geometry) do
          OGR::Geometry.create_from_wkt('LINESTRING (15 5, 5 5)')
        end

        subject { open_line_string.intersects?(other_geometry) }
        it { is_expected.to eq false }
      end
    end
  end
end
