# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-mitm-proxy/version"

Gem::Specification.new do |s|
  s.name        = "em-mitm-proxy"
  s.version     = EventMachine::MitmProxy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Marcin Sawicki"]
  s.email       = ["odcinek@gmail.com"]
  s.homepage    = "http://github.com/odcinek/em-mitm-proxy"
  s.summary     = "Man-in-the-middle http/https transparent http (CONNECT) proxy over bunch of (unreliable) backend proxies"
  s.description = s.summary

  s.rubyforge_project = "em-mitm-proxy"

  s.add_dependency "eventmachine", ">= 1.0.0.beta.4"
  s.add_dependency "redis"
  s.add_dependency "em-http-request"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
