# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'sugarcane/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Robert Qualls"]
  gem.email         = ["robert@robertqualls.com"]
  gem.description   = "Cane with a menu that opens a text editor for each issue"
  gem.summary       = %q{
    Fails your build if code quality thresholds are not met. Provides
    complexity and style checkers built-in, and allows integration with with
    custom quality metrics.
  }
  gem.homepage      = "http://github.com/rlqualls/sugarcane"

  gem.executables   = []
  gem.required_ruby_version = '>= 1.9.0'
  gem.files         = Dir.glob("{spec,lib}/**/*.rb") + %w(
                        README.md
                        HISTORY.md
                        LICENSE
                        sugarcane.gemspec
                      )
  gem.test_files    = Dir.glob("spec/**/*.rb")
  gem.name          = "sugarcane"
  gem.require_paths = ["lib"]
  gem.bindir        = "bin"
  gem.executables  << "sugarcane"
  gem.license       = "Apache 2.0"
  gem.version       = SugarCane::VERSION
  gem.has_rdoc      = false

  gem.add_dependency 'parallel'
  gem.add_dependency 'ncursesw'

  gem.add_development_dependency 'rspec', '~> 2.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'coveralls'
  gem.add_development_dependency 'rspec-fire', '~> 1.2.0'
end
