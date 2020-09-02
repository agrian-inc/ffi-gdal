# typed: false
# frozen_string_literal: true

require 'gdal/geo_transform'

RSpec.describe GDAL::GeoTransform do
  let(:world_file_path) do
    'spec/support/worldfiles/SR_50M/SR_50M.tfw'
  end

  describe '.from_world_file' do
    context 'a valid file' do
      it 'reads in the file' do
        result = described_class.from_world_file(world_file_path)
        expect(result).to be_a GDAL::GeoTransform
      end
    end

    context 'an invalid file' do
      it 'reads in the file' do
        expect do
          described_class.from_world_file('things')
        end.to raise_exception GDAL::OpenFailure
      end
    end
  end

  context 'an imported World file' do
    subject(:world) do
      described_class.from_world_file(world_file_path)
    end

    describe '#x_origin' do
      subject { world.x_origin }
      it { is_expected.to eq(-179.99999999999997) }
    end

    describe '#pixel_width' do
      subject { world.pixel_width }
      it { is_expected.to eq 0.03333333333333 }
    end

    describe '#x_rotation' do
      subject { world.x_rotation }
      it { is_expected.to eq 0.0 }
    end

    describe '#y_origin' do
      subject { world.y_origin }
      it { is_expected.to eq 90.0 }
    end

    describe '#pixel_height' do
      subject { world.pixel_height }
      it { is_expected.to eq(-0.03333333333333) }
    end

    describe '#y_rotation' do
      subject { world.y_rotation }
      it { is_expected.to eq 0.0 }
    end
  end

  context 'a new GeoTransform' do
    describe '#initialize' do
      it 'sets all attributes to 0.0' do
        expect(subject.x_origin).to eq 0.0
        expect(subject.pixel_width).to eq 0.0
        expect(subject.x_rotation).to eq 0.0
        expect(subject.y_origin).to eq 0.0
        expect(subject.pixel_height).to eq 0.0
        expect(subject.y_rotation).to eq 0.0
      end
    end

    describe '#x_origin= + #x_origin' do
      it 'sets the value' do
        subject.x_origin = 123
        expect(subject.x_origin).to eq 123.0
      end
    end

    describe '#pixel_width= + #pixel_width' do
      it 'sets the value' do
        subject.pixel_width = 123
        expect(subject.pixel_width).to eq 123.0
      end
    end

    describe '#x_rotation= + #x_rotation' do
      it 'sets the value' do
        subject.x_rotation = 123
        expect(subject.x_rotation).to eq 123.0
      end
    end

    describe '#y_origin= + #y_origin' do
      it 'sets the value' do
        subject.y_origin = 123
        expect(subject.y_origin).to eq 123.0
      end
    end

    describe '#pixel_width= + #pixel_height' do
      it 'sets the value' do
        subject.pixel_height = 123
        expect(subject.pixel_height).to eq 123.0
      end
    end

    describe '#y_rotation= + #y_rotation' do
      it 'sets the value' do
        subject.y_rotation = 123
        expect(subject.y_rotation).to eq 123.0
      end
    end

    describe '#apply_geo_transform' do
      subject do
        gt = described_class.new
        gt.x_origin = 1000
        gt.y_origin = -2000
        gt.pixel_height = 0.1
        gt.pixel_width = 0.1
        gt
      end

      it "returns the GeoTransform's origins for (0, 0)" do
        projected = subject.apply_geo_transform(0, 0)
        expect(projected[:x_geo]).to eq 1000
        expect(projected[:y_geo]).to eq(-2000)
      end

      it 'returns calculated points' do
        projected = subject.apply_geo_transform(100, 100)
        expect(projected[:x_geo]).to eq 1010.0
        expect(projected[:y_geo]).to eq(-1990.0)
      end
    end

    describe '#compose' do
      context 'given parameter is not a GeoTransform' do
        it 'raises a GDAL::NullObject' do
          expect { subject.compose('not a pointer') }.to raise_exception GDAL::NullObject
        end
      end

      context 'given parameter is a GeoTransform' do
        let(:other_geo_transform) do
          gt = described_class.new
          gt.x_origin = 1000
          gt.y_origin = 1000
          gt.pixel_width = 0.5
          gt.pixel_height = 0.25
          gt.x_rotation = 1.0
          gt.y_rotation = -1.0
          gt
        end

        subject do
          gt = described_class.new
          gt.x_origin = 500
          gt.y_origin = 500
          gt.pixel_width = 0.25
          gt.pixel_height = 0.5
          gt.x_rotation = -1.0
          gt.y_rotation = 1.0

          gt.compose(other_geo_transform)
        end

        it 'is a new GeoTransform' do
          expect(subject).to be_a GDAL::GeoTransform
        end

        it 'has a combined x_origin' do
          expect(subject.x_origin).to eq 1750.0
        end

        it 'has a combined pixel_width' do
          expect(subject.pixel_width).to eq 1.125
        end

        it 'has a combined x_rotation' do
          expect(subject.x_rotation).to eq 0.0
        end

        it 'has a combined y_origin' do
          expect(subject.y_origin).to eq 625.0
        end

        it 'has a combined pixel_height' do
          expect(subject.pixel_height).to eq 1.125
        end

        it 'has a combined y_rotation' do
          expect(subject.y_rotation).to eq 0.0
        end
      end
    end

    describe '#invert' do
      subject do
        gt = described_class.new
        gt.x_origin = 1000
        gt.y_origin = 2000
        gt.pixel_width = 0.5
        gt.pixel_height = 0.5
        gt.x_rotation = 1.0
        gt.y_rotation = -1.0

        gt.invert
      end

      it 'returns a new GeoTransform' do
        expect(subject).to be_a GDAL::GeoTransform
      end

      it 'returns an inverted x_origin' do
        expect(subject.x_origin).to eq 1200
      end

      it 'returns an inverted pixel_width' do
        expect(subject.pixel_width).to eq 0.4
      end

      it 'returns an inverted x_rotation' do
        expect(subject.x_rotation).to eq(-0.8)
      end

      it 'returns an inverted y_origin' do
        expect(subject.y_origin).to eq(-1600.0)
      end

      it 'returns an inverted pixel_height' do
        expect(subject.pixel_height).to eq 0.4
      end

      it 'returns an inverted y_rotation' do
        expect(subject.y_rotation).to eq 0.8
      end
    end
  end
end
