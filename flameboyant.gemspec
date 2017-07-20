# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flameboyant/version'

Gem::Specification.new do |spec|
  spec.name          = 'flameboyant'
  spec.version       = Flameboyant::VERSION
  spec.authors       = ['Scott Pierce']
  spec.email         = ['ddrscott@gmail.com']

  spec.summary       = 'Generate an interactive SVG flame chart'
  spec.homepage      = 'https://github.com/ddrscott/flameboyant'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'ruby-prof'
  spec.add_dependency 'ruby-prof-flamegraph'
end
