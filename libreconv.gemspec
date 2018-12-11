# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libreconv/version'

Gem::Specification.new do |spec|
  spec.name          = 'libreconv'
  spec.version       = Libreconv::VERSION
  spec.authors       = ['Richard Nyström', 'Nathan Broadbent']
  spec.email         = ['nathan@formapi.io']
  spec.description   = 'Convert office documents to PDF using LibreOffice.'
  spec.summary       = 'Convert office documents to PDF.'
  spec.homepage      = 'https://github.com/FormAPI/libreconv'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.add_development_dependency 'bundler', '>= 0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.8.0'
end
