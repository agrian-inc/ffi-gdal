# typed: false
# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  describe '#morph_to_esri!' do
    subject { described_class.new_from_epsg 4326 }

    it 'changes the SRS to ESRI' do
      expect do
        subject.morph_to_esri!
      end.to(change { subject.to_wkt.size })
    end
  end

  describe '#morph_from_esri!' do
    let(:esri) do
      <<-ESRI.strip
        GEOGCS["GCS_North_American_1983",
           DATUM["D_North_American_1983",
           SPHEROID["GRS_1980",6378137,298.257222101]],
           PRIMEM["Greenwich",0],
           UNIT["Degree",0.0174532925199433]]
      ESRI
    end

    subject { described_class.new_from_esri(esri) }

    it 'changes the SRS to ESRI' do
      pending 'Figure out why morphing does not change anything'

      expect do
        subject.morph_from_esri!
      end.to(change { subject.to_wkt.size })
    end
  end
end
