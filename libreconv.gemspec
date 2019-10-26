# encoding: UTF-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
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

  spec.files         = Dir.chdir(File.expand_path('../', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'webmock'
end
