# typed: strict
# frozen_string_literal: true

module FFI
  module OGR
    autoload :API, File.expand_path('ogr/api.rb', __dir__)
    autoload :Core, File.expand_path('ogr/core.rb', __dir__)
    autoload :ContourWriterInfo, File.expand_path('ogr/contour_writer_info.rb', __dir__)
    autoload :Envelope, File.expand_path('ogr/envelope.rb', __dir__)
    autoload :Envelope3D, File.expand_path('ogr/envelope_3d.rb', __dir__)
    autoload :Featurestyle, File.expand_path('ogr/featurestyle.rb', __dir__)
    autoload :Field, File.expand_path('ogr/field.rb', __dir__)
    autoload :Geocoding, File.expand_path('ogr/geocoding.rb', __dir__)
    autoload :SRSAPI, File.expand_path('ogr/srs_api.rb', __dir__)
    autoload :StyleParam, File.expand_path('ogr/style_param.rb', __dir__)
    autoload :StyleValue, File.expand_path('ogr/style_value.rb', __dir__)
  end
end
