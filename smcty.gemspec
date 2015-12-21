require File.expand_path("../lib/smcty/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'smcty'
  s.version     = Smcty::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "A production planning software for simcity(tm)"
  s.description = "Plan your production based on scheduled plans to optimize throughput."
  s.authors     = ["Markus Kuhnt"]
  s.email       = ['markus.kuhnt@gmail.com']

  s.required_rubygems_version = ">= 1.3.6"

  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
  s.executables = ['smcty']

  s.license     = 'MIT'
end
