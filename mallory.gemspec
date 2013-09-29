# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mallory/version"

Gem::Specification.new do |s|
  s.name        = "mallory"
  s.version     = Mallory::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Marcin Sawicki"]
  s.email       = ["odcinek@gmail.com"]
  s.homepage    = "http://github.com/odcinek/mallory"
  s.summary     = "Man-in-the-middle http/https transparent http (CONNECT) proxy over bunch of (unreliable) backends"
  s.description = s.summary
  s.license = "MIT"

  s.add_dependency "eventmachine", "1.0.3"
  s.add_dependency "redis"
  s.add_dependency "em-http-request"
  s.add_dependency "logging"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "sinatra-contrib"
  s.add_development_dependency "thin"
  s.add_development_dependency "rake"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
