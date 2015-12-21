Gem::Specification.new do |s|
  s.name        = 'smcty'
  s.version     = '0.0.1'
  s.executables << 'smcty'
  s.date        = '2015-12-21'
  s.summary     = "A production planning software for simcity(tm)"
  s.description = "Plan your production based on scheduled plans to optimize throughput."
  s.authors     = ["Markus Kuhnt"]
  s.email       = 'markus.kuhnt@gmail.com'
  s.files       = ["lib/smcty.rb", "lib/smcty/configuration.rb", "lib/smcty/configurator.rb", "lib/smcty/console.rb",
        "lib/smcty/factory.rb", "lib/smcty/helpers.rb", "lib/smcty/output.rb", "lib/smcty/project.rb",
        "lib/smcty/production.rb", "lib/smcty/resource.rb", "lib/smcty/scheduling.rb", "lib/smcty/store.rb"]
  s.homepage    = 'https://github.com/mkuhnt/smcty'
  s.license     = 'MIT'
end
