# typed: false
# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::GeometryCollection do
  it_behaves_like 'a geometry' do
    let(:geometry) { described_class.new }
  end

  it_behaves_like 'a container geometry' do
    let(:child_geometry) do
      OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))')
    end
  end

  describe '#to_polygon' do
    let(:polygon) do
      OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))')
    end

    subject do
      gc = described_class.new
      gc.add_geometry(polygon)
      gc
    end

    it 'returns a Polygon' do
      expect(subject.to_polygon).to be_a OGR::Polygon
    end
  end

  describe '#to_multi_polygon' do
    let(:polygon1) do
      OGR::Geometry.create_from_wkt('POLYGON ((0 0,0 1,1 1,1 0,0 0))')
    end

    let(:polygon2) do
      OGR::Geometry.create_from_wkt('POLYGON ((10 10,10 11,11 11,11 10,10 10))')
    end

    subject do
      gc = described_class.new
      gc.add_geometry(polygon1)
      gc.add_geometry(polygon2)
      gc
    end

    it 'returns a MultiPolygon' do
      expect(subject.to_multi_polygon).to be_a OGR::MultiPolygon
    end
  end

  describe '#polygon_from_edges' do
    context 'auto_close is false' do
      subject do
        gc = described_class.new
        gc.add_geometry(line_string1)
        gc.add_geometry(line_string2)
        gc.polygon_from_edges(10, auto_close: false)
      end

      context 'points are not within tolerance' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (100 100,100 20,100 30)')
        end

        it 'raises a OGR::Failure error' do
          expect { subject }.to raise_exception OGR::Failure
        end
      end

      context 'points are within tolerance, not closed' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (1 1,1 2,1 3)')
        end

        it 'returns a Polygon' do
          expect(subject).to be_a OGR::Polygon
        end

        it 'returns WKT with the merged strings' do
          expect(subject.to_wkt).to eq 'POLYGON ((0 0,0 1,0 2,1 1,1 2,1 3))'
        end
      end

      context 'points are within tolerance and closed' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 2,1 4,0 0)')
        end

        it 'returns a Polygon' do
          expect(subject).to be_a OGR::Polygon
        end

        it 'returns WKT with the merged strings' do
          expect(subject.to_wkt).to eq 'POLYGON ((0 0,0 1,0 2,1 4,0 0))'
        end
      end
    end

    context 'auto_close is true' do
      subject do
        gc = described_class.new
        gc.add_geometry(line_string1)
        gc.add_geometry(line_string2)
        gc.polygon_from_edges(10, auto_close: true)
      end

      context 'points are not within tolerance' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (100 100,100 20,0 2)')
        end

        it 'raises a OGR::Failure' do
          expect { subject }.to raise_exception OGR::Failure
        end
      end

      context 'points are within tolerance, not closed' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (1 1,1 2,1 3)')
        end

        it 'returns a Polygon' do
          expect(subject).to be_a OGR::Polygon
        end

        it 'returns WKT with the merged strings' do
          expect(subject.to_wkt)
            .to eq 'POLYGON ((0 0 0,0 1 0,0 2 0,1 1 0,1 2 0,1 3 0,0 0 0))'
        end
      end

      context 'points are within tolerance and already closed' do
        let(:line_string1) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 0,0 1,0 2)')
        end

        let(:line_string2) do
          OGR::Geometry.create_from_wkt('LINESTRING (0 2,1 4,0 0)')
        end

        it 'returns a Polygon' do
          expect(subject).to be_a OGR::Polygon
        end

        it 'returns WKT with the merged strings' do
          expect(subject.to_wkt).to eq 'POLYGON ((0 0,0 1,0 2,1 4,0 0))'
        end
      end

      context 'unsupported geometries' do
        subject do
          gc = described_class.new
          gc.add_geometry(OGR::MultiPolygon.new)
          gc
        end

        it 'raises a GDAL::UnsupportedOperation or OGR::UnsupportedGeometryType' do
          expect do
            subject.polygon_from_edges(100, auto_close: false)
          end.to raise_exception(GDAL::UnsupportedOperation)
        end
      end
    end
  end
end
