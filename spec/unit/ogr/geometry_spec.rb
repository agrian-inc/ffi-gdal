# typed: false
# frozen_string_literal: true

require 'ogr/geometry'

RSpec.describe OGR::Geometry do
  describe '.create_from_wkt' do
    subject { OGR::Geometry.create_from_wkt(wkt) }

    context 'a 2D Point' do
      let(:wkt) { 'POINT(1 32)' }
      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2.5D Point' do
      let(:wkt) { 'POINT(1 32 100)' }
      it { is_expected.to be_a OGR::Point25D }
    end

    context 'a 2D LineString' do
      let(:wkt) { 'LINESTRING(3 19,12 20)' }
      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2.5D LineString' do
      let(:wkt) { 'LINESTRING(3 4 19,12 23 20)' }
      it { is_expected.to be_a OGR::LineString25D }
    end

    context 'a 2D Polygon' do
      let(:wkt) { 'POLYGON((1 1,2 2,3 3))' }
      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2.5D Polygon' do
      let(:wkt) { 'POLYGON((1 1 1,2 2 2,3 3 3))' }
      it { is_expected.to be_a OGR::Polygon25D }
    end

    context 'a 2D MultiPoint' do
      let(:wkt) { 'MULTIPOINT((1 1),(2 2))' }
      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2.5D MultiPoint' do
      let(:wkt) { 'MULTIPOINT((1 1 1),(2 2 2))' }
      it { is_expected.to be_a OGR::MultiPoint25D }
    end

    context 'a 2D MultiLineString' do
      let(:wkt) { 'MULTILINESTRING((3 4),(100 20))' }
      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2.5D MultiLineString' do
      let(:wkt) { 'MULTILINESTRING((3 4 19),(100 20 40))' }
      it { is_expected.to be_a OGR::MultiLineString25D }
    end

    context 'a 2D MultiPolygon' do
      let(:wkt) do
        'MULTIPOLYGON(((1 1,2 2,3 3)),((100 100, 20 20, 30 30)))'
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end

    context 'a 2.5D MultiPolygon' do
      let(:wkt) do
        'MULTIPOLYGON(((1 1 1,2 2 2,3 3 3)),((100 100 100, 20 20 20, 30 30 30)))'
      end

      it { is_expected.to be_a OGR::MultiPolygon25D }
    end
  end

  describe '.create_from_json' do
    subject { OGR::Geometry.create_from_json(json) }

    context 'a 2D Point' do
      let(:json) do
        { type: :Point, coordinates: [1.0, 7.0] }.to_json
      end

      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2.5D Point' do
      let(:json) do
        { type: :Point, coordinates: [1.0, 2.0, 3.0] }.to_json
      end

      it { is_expected.to be_a OGR::Point25D }
    end

    context 'a 2D LineString' do
      let(:json) do
        {
          type: :LineString,
          coordinates: [
            [3.0, 4.0], [20.0, 30.0]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2.5D LineString' do
      let(:json) do
        {
          type: :LineString,
          coordinates: [
            [3.0, 4.0, 19.0], [20.0, 30.0, 45.0]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::LineString25D }
    end

    context 'a 2D Polygon' do
      let(:json) do
        {
          type: :Polygon,
          coordinates: [
            [
              [1.0, 1.0], [5.0, 1.0], [5.0, 5.0], [1.0, 5.0], [1.0, 1.0]
            ]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2.5D Polygon' do
      let(:json) do
        {
          type: :Polygon,
          coordinates: [
            [
              [1.0, 1.0, 1.0], [5.0, 1.0, 1.0], [5.0, 5.0, 1.0], [1.0, 5.0, 1.0], [1.0, 1.0]
            ]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::Polygon25D }
    end

    context 'a 2D MultiPoint' do
      let(:json) do
        {
          type: :MultiPoint,
          coordinates: [
            [1.0, 1.0], [2.0, 2.0], [2.0, 1.0], [1.0, 1.0]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2.5D MultiPoint' do
      let(:json) do
        {
          type: :MultiPoint,
          coordinates: [
            [1.0, 1.0, 1.0], [2.0, 2.0, 2.0], [2.0, 1.0, 2.0], [1.0, 1.0, 1.0]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiPoint25D }
    end

    context 'a 2D MultiLineString' do
      let(:json) do
        {
          type: :MultiLineString,
          coordinates: [
            [
              [3.0, 4.0], [21.0, 27.0], [2.0, 5.0]
            ], [
              [100.0, 20.0], [982.0, 6.0]
            ]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2.5D MultiLineString' do
      let(:json) do
        {
          type: :MultiLineString,
          coordinates: [
            [
              [3.0, 4.0, 19.0], [21.0, 27.0, 30.0]
            ], [
              [100.0, 20.0, 400.0], [92.0, 6.0, 47.1]
            ]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiLineString25D }
    end

    context 'a 2D MultiPolygon' do
      let(:json) do
        {
          type: :MultiPolygon,
          coordinates: [
            [
              [
                [1.0, 1.0], [2.0, 2.0], [3.0, 3.0]
              ], [
                [11.0, 11.0], [10.0, 10.0], [9.0, 9.0]
              ]
            ], [
              [
                [100.0, 100.0], [20.0, 20.0], [30.0, 30.0]
              ], [
                [10.0, 10.0], [20.0, 20.0], [30.0, 30.0]
              ]
            ]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end

    context 'a 2.5D MultiPolygon' do
      let(:json) do
        {
          type: :MultiPolygon,
          coordinates: [
            [
              [
                [1.0, 1.0, 1.0], [2.0, 2.0, 2.0], [3.0, 3.0, 3.0]
              ], [
                [11.0, 11.0, 11.0], [10.0, 10.0, 10.0], [9.0, 9.0, 9.0]
              ]
            ], [
              [
                [100.0, 100.0, 100.0], [20.0, 20.0, 20.0], [30.0, 30.0, 30.0]
              ], [
                [10.0, 10.0, 10.0], [20.0, 20.0, 20.0], [30.0, 30.0, 30.0]
              ]
            ]
          ]
        }.to_json
      end

      it { is_expected.to be_a OGR::MultiPolygon25D }
    end
  end

  describe '.create_from_gml' do
    subject { OGR::Geometry.create_from_gml(gml) }

    context 'a 2D Point' do
      let(:gml) do
        '<gml:Point><gml:coordinates>1,7</gml:coordinates></gml:Point>'
      end

      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2.5D Point' do
      let(:gml) do
        '<gml:Point><gml:coordinates>1,7,25</gml:coordinates></gml:Point>'
      end

      it { is_expected.to be_a OGR::Point25D }
    end

    context 'a 2D LineString' do
      let(:gml) do
        '<gml:LineString><gml:coordinates>3,4</gml:coordinates></gml:LineString>'
      end

      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2.5D LineString' do
      let(:gml) do
        '<gml:LineString><gml:coordinates>3,4,19</gml:coordinates></gml:LineString>'
      end

      it { is_expected.to be_a OGR::LineString25D }
    end

    context 'a 2D Polygon' do
      let(:gml) do
        <<-GML
  <gml:Polygon>
    <gml:outerBoundaryIs>
      <gml:LinearRing>
        <gml:coordinates>1,1 5,1 5,5 1,5 1,1</gml:coordinates>
      </gml:LinearRing>
    </gml:outerBoundaryIs>
  </gml:Polygon>
        GML
      end

      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2.5D Polygon' do
      let(:gml) do
        <<-GML
  <gml:Polygon>
    <gml:outerBoundaryIs>
      <gml:LinearRing>
        <gml:coordinates>1,1,3 5,1,3 5,5,3 1,5,3 1,1,3</gml:coordinates>
      </gml:LinearRing>
    </gml:outerBoundaryIs>
  </gml:Polygon>
        GML
      end

      it { is_expected.to be_a OGR::Polygon25D }
    end

    context 'a 2D MultiPoint' do
      let(:gml) do
        <<-GML
  <gml:MultiPoint>
    <gml:pointMember>
      <gml:Point>
         <gml:coordinates>1,1</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>2,2</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>2,1</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>1,1</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
  </gml:MultiPoint>
        GML
      end

      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2.5D MultiPoint' do
      let(:gml) do
        <<-GML
  <gml:MultiPoint>
    <gml:pointMember>
      <gml:Point>
         <gml:coordinates>1,1,3</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>2,2,3</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>2,1,3</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
    <gml:pointMember>
      <gml:Point>
        <gml:coordinates>1,1,3</gml:coordinates>
      </gml:Point>
    </gml:pointMember>
  </gml:MultiPoint>
        GML
      end

      it { is_expected.to be_a OGR::MultiPoint25D }
    end

    context 'a 2D MultiLineString' do
      let(:gml) do
        <<-GML
  <gml:MultiLineString>
    <gml:lineStringMember>
      <gml:LineString>
        <gml:coordinates>3,4</gml:coordinates>
      </gml:LineString>
    </gml:lineStringMember>
    <gml:lineStringMember>
      <gml:LineString>
        <gml:coordinates>100,20</gml:coordinates>
      </gml:LineString>
    </gml:lineStringMember>
  </gml:MultiLineString>
        GML
      end

      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2.5D MultiLineString' do
      let(:gml) do
        <<-GML
  <gml:MultiLineString>
    <gml:lineStringMember>
      <gml:LineString>
        <gml:coordinates>3,4,19</gml:coordinates>
      </gml:LineString>
    </gml:lineStringMember>
    <gml:lineStringMember>
      <gml:LineString>
        <gml:coordinates>100,20,40</gml:coordinates>
      </gml:LineString>
    </gml:lineStringMember>
  </gml:MultiLineString>
        GML
      end

      it { is_expected.to be_a OGR::MultiLineString25D }
    end

    context 'a 2D MultiPolygon' do
      let(:gml) do
        <<-GML
  <gml:MultiPolygon>
    <gml:polygonMember>
      <gml:Polygon>
        <gml:outerBoundaryIs>
          <gml:LinearRing>
            <gml:coordinates>1,1 2,2 3,3</gml:coordinates>
          </gml:LinearRing>
        </gml:outerBoundaryIs>
      </gml:Polygon>
    </gml:polygonMember>
    <gml:polygonMember>
      <gml:Polygon>
        <gml:outerBoundaryIs>
          <gml:LinearRing>
            <gml:coordinates>100,100 20,20 30,30</gml:coordinates>
          </gml:LinearRing>
        </gml:outerBoundaryIs>
      </gml:Polygon>
    </gml:polygonMember>
  </gml:MultiPolygon>
        GML
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end

    context 'a 2.5D MultiPolygon' do
      let(:gml) do
        <<-GML
  <gml:MultiPolygon>
    <gml:polygonMember>
      <gml:Polygon>
        <gml:outerBoundaryIs>
          <gml:LinearRing>
            <gml:coordinates>1,1,9 2,2,9 3,3,9</gml:coordinates>
          </gml:LinearRing>
        </gml:outerBoundaryIs>
      </gml:Polygon>
    </gml:polygonMember>
    <gml:polygonMember>
      <gml:Polygon>
        <gml:outerBoundaryIs>
          <gml:LinearRing>
            <gml:coordinates>100,100,9 20,20,9 30,30,9</gml:coordinates>
          </gml:LinearRing>
        </gml:outerBoundaryIs>
      </gml:Polygon>
    </gml:polygonMember>
  </gml:MultiPolygon>
        GML
      end

      it { is_expected.to be_a OGR::MultiPolygon25D }
    end
  end

  describe '.create_from_wkb' do
    subject { OGR::Geometry.create_from_wkb(wkb) }

    context 'a 2D Point' do
      # POINT(1 32)
      let(:wkb) { ['0101000000000000000000f03f0000000000004040'].pack('H*') }
      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2.5D Point' do
      # POINT(1 32 100)
      let(:wkb) { ['01e9030000000000000000f03f00000000000040400000000000005940'].pack('H*') }
      it { is_expected.to be_a OGR::Point }
    end

    context 'a 2D LineString' do
      # LINESTRING(3 19,12 20)
      let(:wkb) do
        ['0102000000020000000000000000000840000000000000334000000000000028400000000000003440'].pack('H*')
      end
      it { is_expected.to be_a OGR::LineString }
    end

    context 'a 2.5D LineString' do
      # LINESTRING(3 4 19,12 13 20)
      let(:wkb) do
        hex = '01ea030000020000000000000000000840000000000000104000000000000' \
          '03340000000000000284000000000000037400000000000003440'
        [hex].pack('H*')
      end

      it { is_expected.to be_a OGR::LineString25D }
    end

    context 'a 2D Polygon' do
      # 'POLYGON((1 1,2 1,3 0,1 1))'
      let(:wkb) do
        hex = '01030000000100000004000000000000000000f03f000000000000f03f0000' \
          '000000000040000000000000f03f00000000000008400000000000000000000000' \
          '000000f03f000000000000f03f'
        [hex].pack('H*')
      end

      it { is_expected.to be_a OGR::Polygon }
    end

    context 'a 2.5D Polygon' do
      let(:wkb) do
        # 'POLYGON((1 1 1,2 1 1,2 0 1,1 1 1))'
        hex = '01eb0300000100000004000000000000000000f03f000000000000f03f0000' \
          '00000000f03f0000000000000040000000000000f03f000000000000f03f000000' \
          '00000000400000000000000000000000000000f03f000000000000f03f00000000' \
          '0000f03f000000000000f03f'
        [hex].pack('H*')
      end
      it { is_expected.to be_a OGR::Polygon25D }
    end

    context 'a 2D MultiPoint' do
      let(:wkb) do
        # 'MULTIPOINT((0 0),(1 1))'
        hex = '01040000000200000001010000000000000000000000000000000000000001' \
          '01000000000000000000f03f000000000000f03f'
        [hex].pack('H*')
      end
      it { is_expected.to be_a OGR::MultiPoint }
    end

    context 'a 2.5D MultiPoint' do
      let(:wkb) do
        # 'MULTIPOINT((0 0 0),(1 1 1))'
        hex = '01ec0300000200000001e90300000000000000000000000000000000000000' \
          '0000000000000001e9030000000000000000f03f000000000000f03f0000000000' \
          '00f03f'
        [hex].pack('H*')
      end
      it { is_expected.to be_a OGR::MultiPoint25D }
    end

    context 'a 2D MultiLineString' do
      let(:wkb) do
        # 'MULTILINESTRING((1 1,2 2, 3 3),(10 10,20 20,30 30))'
        hex = '010500000002000000010200000003000000000000000000f03f0000000000' \
          '00f03f000000000000004000000000000000400000000000000840000000000000' \
          '084001020000000300000000000000000024400000000000002440000000000000' \
          '344000000000000034400000000000003e400000000000003e40'
        [hex].pack('H*')
      end
      it { is_expected.to be_a OGR::MultiLineString }
    end

    context 'a 2.5D MultiLineString' do
      let(:wkb) do
        # MULTILINESTRING((3 4 19,100 20 40),(5 5 5,6 6 6,7 7 7))
        hex = '01ed0300000200000001ea0300000200000000000000000008400000000000' \
          '001040000000000000334000000000000059400000000000003440000000000000' \
          '444001ea0300000300000000000000000014400000000000001440000000000000' \
          '14400000000000001840000000000000184000000000000018400000000000001c' \
          '400000000000001c400000000000001c40'
        [hex].pack('H*')
      end
      it { is_expected.to be_a OGR::MultiLineString25D }
    end

    context 'a 2D MultiPolygon' do
      # 'MULTIPOLYGON(((1 1,2 1,2 0,1 1)),((100 100,20 20,30 30,100 100)))'
      let(:wkb) do
        hex = '01060000000200000001030000000100000004000000000000000000f03f00' \
          '0000000000f03f0000000000000040000000000000f03f00000000000000400000' \
          '000000000000000000000000f03f000000000000f03f0103000000010000000400' \
          '000000000000000059400000000000005940000000000000344000000000000034' \
          '400000000000003e400000000000003e4000000000000059400000000000005940'
        [hex].pack('H*')
      end

      it { is_expected.to be_a OGR::MultiPolygon }
    end

    context 'a 2.5D MultiPolygon' do
      # 'MULTIPOLYGON(((1 1 1,2 1 2,2 0 3,1 1 1)),((100 100 100,20 20 20,30 30 30,100 100 100)))'
      let(:wkb) do
        hex = '01ee0300000200000001eb0300000100000004000000000000000000f03f00' \
          '0000000000f03f000000000000f03f0000000000000040000000000000f03f0000' \
          '000000000040000000000000004000000000000000000000000000000840000000' \
          '000000f03f000000000000f03f000000000000f03f01eb03000001000000040000' \
          '000000000000005940000000000000594000000000000059400000000000003440' \
          '000000000000344000000000000034400000000000003e400000000000003e4000' \
          '00000000003e40000000000000594000000000000059400000000000005940'
        [hex].pack('H*')
      end

      it { is_expected.to be_a OGR::MultiPolygon25D }
    end
  end

  describe '.type_to_name' do
    context 'wkbUnknown' do
      subject { described_class.type_to_name(:wkbUnknown) }
      it { is_expected.to eq 'Unknown (any)' }
    end

    context 'wkbPoint' do
      subject { described_class.type_to_name(:wkbPoint) }
      it { is_expected.to eq 'Point' }
    end

    context 'wkbLineString' do
      subject { described_class.type_to_name(:wkbLineString) }
      it { is_expected.to eq 'Line String' }
    end

    context 'wkbPolygon' do
      subject { described_class.type_to_name(:wkbPolygon) }
      it { is_expected.to eq 'Polygon' }
    end

    context 'wkbMultiPoint' do
      subject { described_class.type_to_name(:wkbMultiPoint) }
      it { is_expected.to eq 'Multi Point' }
    end

    context 'wkbMultiLineString' do
      subject { described_class.type_to_name(:wkbMultiLineString) }
      it { is_expected.to eq 'Multi Line String' }
    end

    context 'wkbMultiPolygon' do
      subject { described_class.type_to_name(:wkbMultiPolygon) }
      it { is_expected.to eq 'Multi Polygon' }
    end

    context 'wkbGeometryCollection' do
      subject { described_class.type_to_name(:wkbGeometryCollection) }
      it { is_expected.to eq 'Geometry Collection' }
    end

    context 'wkbNone' do
      subject { described_class.type_to_name(:wkbNone) }
      it { is_expected.to eq 'None' }
    end

    context 'wkbLinearRing' do
      subject { described_class.type_to_name(:wkbLinearRing) }
      it { is_expected.to eq 'Unrecognized: 101' }
    end
  end

  describe '#utm_zone' do
    let(:geom) { OGR::Geometry.create_from_wkt(wkt) }

    let(:wkt) do
      'LINESTRING(100 100, 20 20, 30 30, 100 100)'
    end

    context 'no spatial_reference' do
      subject { geom.utm_zone }
      it { is_expected.to be_nil }
    end

    context 'SRID is 4326' do
      subject { geom.utm_zone }
      before { geom.spatial_reference = OGR::SpatialReference.new_from_epsg(4326) }
      it { is_expected.to eq(36) }
    end

    context 'SRID is not 4326' do
      before { geom.spatial_reference = OGR::SpatialReference.new_from_epsg(3857) }

      it 'transforms to 4326 then figures out the zone' do
        duped_subject = geom.clone
        expect(geom).to receive(:clone).and_return(duped_subject)
        expect(duped_subject).to receive(:transform_to!).and_call_original

        geom.utm_zone
      end
    end
  end
end
