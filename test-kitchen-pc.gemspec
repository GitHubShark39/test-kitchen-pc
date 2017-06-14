# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/pc/version"
require "English"

Gem::Specification.new do |gem|
  gem.name          = 'test-kitchen-pc'
  gem.version       = Kitchen::PC::VERSION
  gem.license       = 'MIT'
  gem.authors       = ['Russell Snyder']
  gem.email         = ['ru.snyder@gmail.com']
  gem.summary       = 'Test Kitchen Parent-Child adds config inheritance to '\
                      'Test Kitchen .kitchen.yml files'
  gem.description   = 'Test Kitchen Parent-Child is a thin wrapper around ' \
                      'Test Kitchen that adds support for inheritance in the ' \
                      '.kitchen.yml configuration files for multi-role projects.'
  gem.homepage      = 'https://github.com/rusnyder/test-kitchen-pc'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = %w{kitchen-pc}
  #gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.3"

  gem.add_dependency 'test-kitchen', '>= 1.0.0'

  # General test/build gems
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'

  # Integration testing gems
  gem.add_development_dependency 'kitchen-inspec', '~> 0.14'
end
