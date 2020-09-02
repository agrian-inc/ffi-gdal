# typed: false
# frozen_string_literal: true

require 'ogr/layer'

RSpec.describe OGR::Layer do
  include_context 'OGR::Layer, spatial_reference'

  describe '#feature_definition' do
    it 'returns a OGR::FeatureDefinition' do
      expect(subject.feature_definition).to be_a OGR::FeatureDefinition
    end
  end

  describe '#create_feature' do
    let(:feature) { OGR::Feature.new(subject.feature_definition) }

    context 'creation is not supported' do
      before { expect(subject).to receive(:can_sequential_write?).and_return(false) }

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.create_feature(feature) }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'creation is supported' do
      it do
        expect(subject.create_feature(feature)).to be_nil
      end
    end
  end

  describe '#delete_feature' do
    context 'deletion is not supported' do
      before { expect(subject).to receive(:can_delete_feature?).and_return(false) }

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.delete_feature(0) }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'deletion is supported' do
      context 'no features' do
        it 'raises an OGR::Failure' do
          expect { subject.delete_feature(0) }.to raise_exception OGR::Failure
        end
      end

      context 'has a feature' do
        before { subject.create_feature(OGR::Feature.new(subject.feature_definition)) }

        it 'returns nil' do
          expect(subject.delete_feature(0)).to be_nil
        end
      end
    end
  end

  describe '#feature_count' do
    it 'returns the number of features' do
      expect(subject.feature_count).to be_zero
    end
  end

  describe '#feature' do
    context 'cannot random read' do
      before { expect(subject).to receive(:can_random_read?).and_return(false) }

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.feature(0) }.to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'can random read' do
      context 'no features' do
        it 'returns nil' do
          expect(subject.feature(0)).to be_nil
        end
      end

      context 'has a feature' do
        before { subject.create_feature(OGR::Feature.new(subject.feature_definition)) }

        it 'returns an OGR::Feature' do
          expect(subject.feature(0)).to be_a OGR::Feature
        end
      end
    end
  end

  describe '#feature=' do
    context 'cannot random write' do
      before { expect(subject).to receive(:can_random_write?).and_return(false) }

      it 'raises an OGR::UnsupportedOperation' do
        expect { subject.feature = OGR::Feature.new(subject.feature_definition) }
          .to raise_exception OGR::UnsupportedOperation
      end
    end

    context 'can random write' do
      it 'adds the feature' do
        skip
      end
    end
  end

  describe 'next_feature' do
    context 'no features' do
      it 'returns nil' do
        expect(subject.next_feature).to be_nil
      end
    end

    context 'has a feature' do
      before { layer.create_feature(OGR::Feature.new(layer.feature_definition)) }
      subject { layer.next_feature }
      after { subject.destroy! }

      it 'returns an OGR::Feature' do
        expect(subject).to be_a OGR::Feature
      end
    end
  end

  describe '#next_feature_index=' do
    context 'no features' do
      it 'raises an OGR::Failure' do
        expect { subject.next_feature_index = 123 }
          .to raise_exception OGR::Failure
      end
    end

    context 'features exist' do
      let!(:feature1) do
        layer.create_feature(OGR::Feature.new(layer.feature_definition))
      end

      let!(:feature2) do
        layer.create_feature(OGR::Feature.new(layer.feature_definition))
      end

      subject do
        layer.next_feature_index = 1
        layer.next_feature
      end

      after { subject.destroy! }

      it 'sets to the given feature' do
        expect(subject).to_not be_nil
      end
    end
  end
end
