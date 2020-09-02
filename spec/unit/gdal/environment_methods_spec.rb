# typed: false
# frozen_string_literal: true

require 'gdal/environment_methods'

RSpec.describe GDAL::EnvironmentMethods do
  subject { Object.new.extend(described_class) }
end
