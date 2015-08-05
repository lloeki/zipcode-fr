Gem::Specification.new do |s|
  s.name        = 'zipcode-fr'
  s.version     = '1.1.0'
  s.licenses    = ['MIT']
  s.summary     = 'French zip codes and cities'
  s.description = <<-EOS
   Query city information by zip code and city name, indexed by word prefixes.
  EOS
  s.authors     = ['Loic Nageleisen']
  s.email       = 'loic.nageleisen@gmail.com'
  s.files       = Dir['lib/**/*.rb'] + Dir['vendor/**/*']
  s.homepage    = 'https://github.com/lloeki/zipcode-fr'

  s.add_dependency 'zipcode-db', '~> 1.0'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
end
