Gem::Specification.new do |s|
  s.name        = 'database_cleaner_seeded'
  s.version     = '0.0.1'
  s.date        = '2016-08-09'
  s.summary     = 'Restore database state between feature tests using SQL'
  s.description = 'Provide a strategy for maintaining database state between feature tests, that uses your DBMS to inject generated seeds directly.'
  s.authors     = ['Michael Dawson']
  s.email       = 'email.michaeldawson@gmail.com'
  s.files       = ['lib/database_cleaner.rb']
  s.homepage    = 'http://rubygems.org/gems/database_cleaner_seeded'
  s.license       = 'MIT'

  s.add_dependency('database_cleaner')
end
