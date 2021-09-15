# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-maskrx"
  spec.version       = "0.0.1-pre1"
  spec.authors       = ["Joshua Mervine"]
  spec.email         = ["joshua@mervine.net"]
  spec.summary       = %q{Fluentd filter plugin to mask strings within records.}
  spec.homepage      = "https://github.com/jmervine/fluent-plugin-maskrx"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "test-unit", "~> 3"
  spec.add_runtime_dependency "fluentd", [">= 0.14.0", "< 2"]
end

