# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'resque/plugins/filter/version'

Gem::Specification.new do |s|
  s.name        = "resque-filter"
  s.version     = Resque::Plugins::Filter::VERSION
  s.authors     = ["Matt Conway"]
  s.email       = ["matt@conwaysplace.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "resque-filter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("resque", '~> 1.10')
  
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('rack-test', '~> 0.5.4')

  # Needed for testing newer resque on ruby 1.8.7
  s.add_development_dependency('json')
  # Needed for correct ordering when passing hash params to rack-test
  s.add_development_dependency('orderedhash')
end
