# typed: false
# frozen_string_literal: true

require 'ffi-gdal'
require 'gdal'

RSpec.describe 'GeoTransform Info', type: :integration do
  let(:file) { make_temp_test_file(original_source_tiff) }

  let(:original_source_tiff) do
    path = '../../../spec/support/images/osgeo/geotiff/zi_imaging/image0.tif'
    File.expand_path(path, __dir__)
  end

  let(:dataset) { GDAL::Dataset.open(file, 'r') }
  after { dataset.close }
  subject { dataset.geo_transform }

  describe '#x_origin' do
    it 'is a Float' do
      expect(subject.x_origin).to be_a Float
    end
  end

  describe '#x_origin=' do
    context 'param is a number' do
      it 'sets the value' do
        expect { subject.x_origin = 12.34 }.to change { subject.x_origin }
          .from(-12.51100000000001).to(12.34)
      end
    end

    context 'param is not a number' do
      it 'raises a TypeError' do
        expect { subject.x_origin = [] }.to raise_exception TypeError
      end
    end
  end

  describe '#y_origin' do
    it 'is a Float' do
      expect(subject.y_origin).to be_a Float
    end
  end

  describe '#y_origin=' do
    context 'param is a number' do
      it 'sets the value' do
        expect { subject.y_origin = 12.34 }.to change { subject.y_origin }
          .from(109.03599999999999).to(12.34)
      end
    end

    context 'param is not a number' do
      it 'raises a TypeError' do
        expect { subject.y_origin = [] }.to raise_exception TypeError
      end
    end
  end

  describe '#pixel_width' do
    it 'is a Float' do
      expect(subject.pixel_width).to be_a Float
    end
  end

  describe '#pixel_width=' do
    context 'param is a number' do
      it 'sets the value' do
        expect { subject.pixel_width = 12.34 }.to change { subject.pixel_width }
          .from(0).to(12.34)
      end
    end

    context 'param is not a number' do
      it 'raises a TypeError' do
        expect { subject.pixel_width = [] }.to raise_exception TypeError
      end
    end
  end

  describe '#x_rotation' do
    it 'is a Float' do
      expect(subject.x_rotation).to be_a Float
    end
  end

  describe '#x_rotation=' do
    context 'param is a number' do
      it 'sets the value' do
        expect { subject.x_rotation = 12.34 }.to change { subject.x_rotation }
          .from(0.1850509803921595).to(12.34)
      end
    end

    context 'param is not a number' do
      it 'raises a TypeError' do
        expect { subject.x_rotation = [] }.to raise_exception TypeError
      end
    end
  end

  describe '#y_rotation' do
    it 'is a Float' do
      expect(subject.y_rotation).to be_a Float
    end
  end

  describe '#y_rotation=' do
    context 'param is a number' do
      it 'sets the value' do
        expect { subject.y_rotation = 12.34 }.to change { subject.y_rotation }
          .from(-0.3001842105263167).to(12.34)
      end
    end

    context 'param is not a number' do
      it 'raises a TypeError' do
        expect { subject.y_rotation = [] }.to raise_exception TypeError
      end
    end
  end

  describe '#pixel_height' do
    it 'is a Float' do
      expect(subject.pixel_height).to be_a Float
    end
  end

  describe '#pixel_height=' do
    context 'param is a number' do
      it 'sets the value' do
        expect { subject.pixel_height = 12.34 }.to change { subject.pixel_height }
          .from(0.0).to(12.34)
      end
    end

    context 'param is not a number' do
      it 'raises a TypeError' do
        expect { subject.pixel_height = [] }.to raise_exception TypeError
      end
    end
  end

  describe '#apply_geo_transform' do
    context 'valid pixel and line' do
      it 'returns a Hash with mapped geo values' do
        expect(subject.apply_geo_transform(1, 1)).to eq(x_geo: -12.325949019607851, y_geo: 108.73581578947368)
      end
    end

    context 'really large pixel and line' do
      it '(oddly) returns a Hash with mapped geo values' do
        expect(subject.apply_geo_transform(1_000_000_000_000, 10_000_000_000_000))
          .to eq(x_geo: 1_850_509_803_909.084, y_geo: -300_184_210_417.2807)
      end
    end

    context 'pixel and line are not numbers' do
      it 'raises a TypeError' do
        expect { subject.apply_geo_transform({}, 'stuff') }.to raise_exception(TypeError)
      end
    end
  end

  describe '#compose' do
    let(:other_geo_transform) do
      gt = GDAL::GeoTransform.new
      gt.x_origin = -1
      gt.y_origin = 1
      gt.pixel_width = 2
      gt.pixel_height = 0.5
      gt.x_rotation = 1
      gt.y_rotation = -1

      gt
    end

    it 'returns a new GeoTransform' do
      composed_gt = subject.compose(other_geo_transform)
      expect(composed_gt).to be_a GDAL::GeoTransform

      expect(composed_gt.x_origin).to eq(83.01399999999997)
      expect(composed_gt.y_origin).to eq(68.029)
      expect(composed_gt.pixel_width).to eq(-0.3001842105263167)
      expect(composed_gt.pixel_height).to eq(-0.1850509803921595)
      expect(composed_gt.x_rotation).to eq(0.370101960784319)
      expect(composed_gt.y_rotation).to eq(-0.15009210526315836)
    end
  end

  describe '#invert' do
    it 'returns a new GeoTransform' do
      inverted_gt = subject.invert

      expect(inverted_gt).to be_a GDAL::GeoTransform
      expect(inverted_gt.x_origin).to eq(363.2302971859373)
      expect(inverted_gt.y_origin).to eq(67.60839620242344)
      expect(inverted_gt.pixel_width).to eq(0)
      expect(inverted_gt.pixel_height).to eq(0)
      expect(inverted_gt.x_rotation).to eq(-3.3312878057333113)
      expect(inverted_gt.y_rotation).to eq(5.403916249893964)
    end
  end

  describe '#to_world_file' do
    after { File.unlink('tmp/meow') if File.exist?('tmp/meow') }

    it 'writes out to a file with the given extension' do
      subject.to_world_file('tmp/meow', 'wld')

      file = File.expand_path('tmp/meow.wld')
      expect(File.exist?(file)).to eq true
      contents = File.readlines(file).map(&:strip)

      # I don't understand why the resulting world file has slightly different
      # values than those from the GeoTransform...
      expect(contents[0].to_f).to eq(subject.pixel_width)
      expect(contents[1].to_f).to be_within(0.00000001).of(subject.y_rotation)
      expect(contents[2].to_f).to be_within(0.00000001).of(subject.x_rotation)
      expect(contents[3].to_f).to eq(subject.pixel_height)
      expect(contents[4].to_f).to be_within(0.1).of(subject.x_origin)
      expect(contents[5].to_f).to be_within(0.3).of(subject.y_origin)
    end
  end
end
