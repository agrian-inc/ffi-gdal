# typed: false
# frozen_string_literal: true

require 'ogr/internal_helpers'

RSpec.describe OGR::InternalHelpers do
  subject(:tester) do
    module Tester
      include OGR::InternalHelpers
    end
  end

  describe '._boolean_access_flag' do
    context "when 'w'" do
      subject { tester._boolean_access_flag('w') }
      it { is_expected.to eq true }
    end

    context "when 'r'" do
      subject { tester._boolean_access_flag('r') }
      it { is_expected.to eq false }
    end

    context 'when anything else' do
      it 'raises a RuntimeError' do
        expect { tester._boolean_access_flag('a') }.to raise_exception RuntimeError
      end
    end
  end

  describe '._format_time_zone_for_ruby' do
    context 'time_zone is 0' do
      subject { tester._format_time_zone_for_ruby(0) }
      it { is_expected.to be_nil }
    end

    context 'time_zone is 1' do
      subject { tester._format_time_zone_for_ruby(1) }
      it { is_expected.to be_a String }
      it { is_expected.to_not be_empty }
    end

    context 'time_zone is 100' do
      subject { tester._format_time_zone_for_ruby(100) }
      it { is_expected.to eq '+0' }
    end
  end

  describe '._format_time_zone_for_ogr' do
    context 'GMT' do
      subject { tester._format_time_zone_for_ogr('GMT') }
      it { is_expected.to eq 100 }
    end

    context '+00:00' do
      subject { tester._format_time_zone_for_ogr('+00:00') }
      it { is_expected.to eq 100 }
    end

    context 'not nil and not GMT' do
      subject { tester._format_time_zone_for_ogr('asdf') }
      it { is_expected.to eq 1 }
    end

    context 'nil' do
      subject { tester._format_time_zone_for_ogr(nil) }
      it { is_expected.to eq 0 }
    end
  end
end
