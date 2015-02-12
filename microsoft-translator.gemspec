# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'microsoft/translator/version'

Gem::Specification.new do |spec|
  spec.name          = "microsoft-translator"
  spec.version       = Microsoft::Translator::VERSION
  spec.authors       = ["Aaron Webster"]
  spec.email         = ["aaron.l.webster@gmail.com"]
  spec.summary       = %q{Ruby wrapper for Microsoft Translator HTTP API.}
  spec.description   = %q{Use this wrapper to easily detect and translate languages.}
  spec.homepage      = "https://github.com/cathawk/microsoft-translator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "webmock", "~> 1.20"
  spec.add_development_dependency "vcr", "~> 2.9"
  spec.add_runtime_dependency     "httparty", "~> 0.13"
end
