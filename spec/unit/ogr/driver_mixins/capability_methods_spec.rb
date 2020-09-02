# typed: false
# frozen_string_literal: true

require 'ogr/driver'

RSpec.describe OGR::Driver do
  context 'Memory driver' do
    subject(:driver) { OGR::Driver.by_name('Memory') }

    describe '#can_create_data_source?' do
      subject { driver.can_create_data_source? }
      it { is_expected.to eq true }
    end

    describe '#can_delete_data_source?' do
      subject { driver.can_delete_data_source? }
      it { is_expected.to eq false }
    end
  end
end
