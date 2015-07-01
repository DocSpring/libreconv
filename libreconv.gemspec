# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libreconv/version'

Gem::Specification.new do |spec|
  spec.name          = "libreconv"
  spec.version       = Libreconv::VERSION
  spec.authors       = ["Richard Nyström"]
  spec.email         = ["ricny046@gmail.com"]
  spec.description   = %q{ Convert office documents to PDF using LibreOffice. }
  spec.summary       = %q{ Convert office documents to PDF. }
  spec.homepage      = "https://github.com/ricn/libreconv"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency "spoon"
  spec.add_development_dependency "bundler", ">= 0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.2.0"
end
