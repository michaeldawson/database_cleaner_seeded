Gem::Specification.new do |s|
  s.name        = 'database_cleaner_seeded'
  s.version     = '0.1.1'
  s.date        = '2016-08-09'
  s.summary     = 'Seed database directly between feature tests'
  s.description = 'Provide a strategy for injecting database seeds between feature tests, using the DBMS directly.'
  s.authors     = ['Michael Dawson']
  s.email       = 'email.michaeldawson@gmail.com'
  s.files       = ['lib/database_cleaner_seeded.rb']
  s.homepage    = 'http://rubygems.org/gems/database_cleaner_seeded'
  s.license       = 'MIT'

  s.add_dependency('database_cleaner', '>= 1.2.0')
  s.add_dependency('activerecord', '> 3.0')
  s.add_dependency('rspec')
end
