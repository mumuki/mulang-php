# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mulang/php/version'

Gem::Specification.new do |spec|
  spec.name          = "mulang-php"
  spec.version       = Mulang::PHP::VERSION
  spec.authors       = ["Rodrigo Alfonso", "Franco Leonardo Bulgarelli"]
  spec.email         = ["rodri042@gmail.com", "franco@mumuki.org"]

  spec.summary       = "PHP integration for the Mulang Language Analyzer"
  spec.description   = "PHP - Mulang Parser"
  spec.homepage      = "https://mumuki.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"

  spec.add_dependency "ast", "~> 2.4"
  spec.add_dependency "mumukit-core", "~> 1.0"
  spec.add_dependency "mulang", "~> 6.0"
end
