# typed: false
# frozen_string_literal: true

require 'gdal/grid'

RSpec.describe GDAL::Grid do
  subject(:grid) { described_class.new(:metric_count) }

  describe 'attributes' do
    it { is_expected.to respond_to :data_type }
    it { is_expected.to respond_to :data_type= }
    it { is_expected.to respond_to :algorithm_options }
    it { is_expected.to respond_to :algorithm_type }
    it { is_expected.to respond_to :algorithm_type }
  end

  describe '#create' do
    context 'no points to grid' do
      it 'raises a GDAL::NoValuesToGrid' do
        expect { subject.create([], {}, nil) }.to raise_exception GDAL::NoValuesToGrid
      end
    end
  end

  describe '#make_points_pointer' do
    context 'array has values' do
      let(:points) { [1, 2, 3, 4] }

      it 'creates a FFI::MemoryPointer from the given array of points' do
        pointer = subject.send(:make_points_pointer, points)
        expect(pointer).to be_an_instance_of FFI::MemoryPointer
        expect(pointer.read_array_of_double(points.length)).to eq(points)
      end
    end

    context 'array has only nil values' do
      let(:points) { [nil, nil] }

      it 'raises a GDAL::Error' do
        expect { subject.send(:make_points_pointer, points) }.to raise_error GDAL::Error
      end
    end
  end

  describe '#init_algorithm' do
    context 'inverse_distance_to_a_power' do
      subject { grid.send(:init_algorithm, :inverse_distance_to_a_power) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::InverseDistanceToAPower) }
    end

    context 'moving_average' do
      subject { grid.send(:init_algorithm, :moving_average) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::MovingAverage) }
    end

    context 'nearest_neighbor' do
      subject { grid.send(:init_algorithm, :nearest_neighbor) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::NearestNeighbor) }
    end

    context 'metric_average_distance' do
      subject { grid.send(:init_algorithm, :metric_average_distance) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::MetricAverageDistance) }
    end

    context 'metric_average_distance_pts' do
      subject { grid.send(:init_algorithm, :metric_average_distance_pts) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::MetricAverageDistancePts) }
    end

    context 'metric_count' do
      subject { grid.send(:init_algorithm, :metric_count) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::MetricCount) }
    end

    context 'metric_maximum' do
      subject { grid.send(:init_algorithm, :metric_maximum) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::MetricMaximum) }
    end

    context 'metric_minimum' do
      subject { grid.send(:init_algorithm, :metric_minimum) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::MetricMinimum) }
    end

    context 'metric_range' do
      subject { grid.send(:init_algorithm, :metric_range) }
      it { is_expected.to be_an_instance_of(GDAL::GridAlgorithms::MetricRange) }
    end

    context 'unknown algorithm' do
      it 'raises a GDAL::UnknownGridAlgorithm' do
        expect { grid.send(:init_algorithm, :metric_pants) }
          .to raise_exception(GDAL::UnknownGridAlgorithm)
      end
    end
  end
end
