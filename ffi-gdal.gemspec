# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffi/gdal/version'

Gem::Specification.new do |spec|
  spec.name          = 'ffi-gdal'
  spec.version       = FFI::GDAL::VERSION
  spec.authors       = ['Steve Loveless']
  spec.email         = %w[steve@agrian.com]
  spec.summary       = 'FFI wrapper for GDAL/OGR.'
  spec.homepage      = 'http://bitbucket.org/agrian/ffi-gdal'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = %w[lib]

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'ffi'
  spec.add_dependency 'log_switch', '~> 1.0.0'
  spec.add_dependency 'multi_xml'
  spec.add_dependency 'narray', '~> 0.6.0'
  spec.add_dependency 'sorbet-runtime'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-checkstyle_formatter'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'sorbet'
end
