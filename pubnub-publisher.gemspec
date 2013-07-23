# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pubnub/publisher/version'

Gem::Specification.new do |spec|
  spec.name          = "pubnub-publisher"
  spec.version       = Pubnub::Publisher::VERSION
  spec.authors       = ["Matt Aimonetti"]
  spec.email         = ["mattaimonetti@gmail.com"]
  spec.description   = %q{The simplest PubNub gem possible to simply publish events. Nothing more.}
  spec.summary       = %q{Because when you only care to publish events, you don't want to load a bunch of unneeded dependencies.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
