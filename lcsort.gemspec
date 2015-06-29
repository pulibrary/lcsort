# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lcsort/version'

Gem::Specification.new do |spec|
  spec.name          = "lcsort"
  spec.version       = Lcsort::VERSION
  spec.authors       = ["Nikitas Tampakis", "Jonathan Rochkind"]
  spec.email         = ["tampakis@princeton.edu"]

  spec.summary       = %q{Sort-normalized forms of LC Call Numbers}
  spec.description   = %q{Sort-order-normalize Library of Congress call numbers and determine search ranges for left-anchor search}
  #spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
