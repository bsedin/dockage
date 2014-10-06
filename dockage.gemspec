# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dockage/version'

Gem::Specification.new do |spec|
  spec.name          = 'dockage'
  spec.version       = Dockage::VERSION
  spec.authors       = ['Sergey Besedin']
  spec.email         = ['kr3ssh@gmail.com']
  spec.summary       = 'Control multiple docker containers with ease'
  spec.description   = 'Gem to manage multiple docker containers at once'
  spec.homepage      = 'http://github.com/kr3ssh/dockage'
  spec.license       = 'MIT'

  spec.required_ruby_version     = '>= 1.9'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = %w( dockage )
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_dependency 'hashie'
  spec.add_dependency 'thor'
  spec.add_dependency 'colorize'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
