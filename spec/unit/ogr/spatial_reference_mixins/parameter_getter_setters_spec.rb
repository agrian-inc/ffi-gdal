# typed: false
# frozen_string_literal: true

require 'ogr/spatial_reference'

RSpec.describe OGR::SpatialReference do
  # Not sure why yet, but it seems I can only do angular unit setting with
  # certain projections; 4326 is one of them.
  describe '#set_angular_units + #angular_units' do
    subject { OGR::SpatialReference.new_from_epsg(4326) }

    context 'using a known label and value' do
      it 'sets the new label and value' do
        subject.set_angular_units(OGR::SpatialReference::RADIAN_LABEL, 1.0)
        expect(subject.angular_units).to eq(unit_name: 'radian', value: 1.0)
      end
    end

    context 'using an unknown label and value' do
      it 'sets the new label and value' do
        subject.set_angular_units('Darrels', 25.6)
        expect(subject.angular_units).to eq(unit_name: 'Darrels', value: 25.6)
      end
    end
  end

  # Not sure why yet, but it seems I can only do linear unit setting with
  # certain projections; 4333 is one of them.
  describe '#set_linear_units + #linear_units' do
    subject { OGR::SpatialReference.new_from_epsg(4333) }

    context 'using a known label and value' do
      it 'sets the new label and value' do
        subject.set_linear_units(OGR::SpatialReference::FOOT_LABEL, OGR::SpatialReference::METER_TO_FOOT)
        expect(subject.linear_units).to eq(unit_name: 'Foot (International)', value: 0.3048)
      end
    end

    context 'using an unknown label and value' do
      it 'sets the new label and value' do
        subject.set_linear_units('Darrels', 25.6)
        expect(subject.linear_units).to eq(unit_name: 'Darrels', value: 25.6)
      end
    end
  end

  # Not sure why yet, but it seems I can only do linear unit setting with
  # certain projections; 4333 is one of them.
  describe '#set_linear_units_and_update_parameters + #linear_units' do
    subject { OGR::SpatialReference.new_from_epsg(4333) }

    context 'using a known label and value' do
      it 'sets the new label and value' do
        subject.set_linear_units_and_update_parameters(OGR::SpatialReference::FOOT_LABEL,
                                                       OGR::SpatialReference::METER_TO_FOOT)
        expect(subject.linear_units).to eq(unit_name: 'Foot (International)', value: 0.3048)
      end
    end

    context 'using an unknown label and value' do
      it 'sets the new label and value' do
        subject.set_linear_units('Darrels', 25.6)
        expect(subject.linear_units).to eq(unit_name: 'Darrels', value: 25.6)
      end
    end
  end
end
