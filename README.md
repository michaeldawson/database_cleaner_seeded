# 'Seeded' strategy for Database Cleaner + Active Record

Restore the database to a seeded state between tests, in a way that's compatible with feature tests that are run in multiple threads.

## Why?

The fantastic DatabaseCleaner gem provides a range of strategies for cleaning your database between RSpec tests. The gem's 'transaction' strategy is a fast way to rollback database state, and can be used to rollback your database state to a seeded baseline between tests. However, it isn't compatible with tests that run with multiple threads (e.g. using Capybara + Selenium), and so to make seed data available for these tests, you may need to run seed code before each test case.

This gem allows you to restore the database to a seeded state using direct DBMS operations (using raw SQL) instead of ruby code. If you have a test suite with a large reliance on seeded data, this gem may speed up your test suite. I've seen speed benefits of up to 30% with some projects.

## How?

Before your feature test suite runs, a code block is run once to generate a raw seeds file. Then, before each test is run, your database is restored using direct injection of those seeds. This is usually faster than generating seeds using Ruby and inserting them individually before each test... but, because of the overhead associated with this approach, YMMV.

Currently, this gem only supports MYSQL, and doesn't support database connections that require a password.

To get started, add this gem to your Gemfile, point it to a method to call to call to setup your feature test seeds, and add some setup code to your `spec/rails_helper.rb` file.

```ruby
# Gemfile

gem 'database_cleaner_seeded'
```

```ruby
# spec/support/seed_data_helper.rb

def seed_for_every_feature_test
  seed_foos
  seed_bars
  seed_bazzes
end
```

```ruby
# spec/rails_helper.rb

# ...

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

require 'database_cleaner/active_record/seeded'

include SeedDataHelper

RSpec.configure do |config|
  # ...

  config.before(:suite) do
    # Prepare the seeds file if we're running feature tests in this test run

    if config.files_to_run.any? {|f| /spec\/features\//.match(f) }
      DatabaseCleaner.prepare_with(:seeded) { seed_for_every_feature_test }
    end
  end

  config.around(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:type] == :feature ? :seeded : :transaction
    DatabaseCleaner.cleaning { example.run }
  end
end
```

## Options

With the above configuration, the code you run inside `DatabaseCleaner.prepare_with(:seeded)` is run each time you run your test suite with feature tests. However, depending on your requirements and the way that you run your test suite, you might like to skip seed regeneration between test runs, for faster performance. However - be warned! Use with caution - if you change your data model and don't regenerate the seeds, you might experience failures that are hard to diagnose.

This gem exposes an option for you to selectively skip seed regeneration, in the form of a proc. You may also override the seeds file path (`tmp/tmp/database_cleaner_seeds.sql` by default).

```ruby
DatabaseCleaner::Seeded.configure do |config|
  config.skip_seed_regeneration = -> { ! ENV['RESEED'] }
  config.seeds_file_path = 'spec/fixtures/feature_test_seeds.sql'
end
```

Using this configuration, existing seeds will be used between test suite runs. But, running `RESEED=true rspec spec/features` will force regeneration of the seeds.

## Todo

- Add support for other DBMSs
- Add in some integration tests - perhaps with a mounted test application
- Profit

## Development & Feedback

Have questions or encountered problems? Please use the
[issue tracker](https://github.com/michaeldawson/database_cleaner_seeded/issues). If you would like to contribute to this project, fork this repository, then run `bundle` and `rake` to run the tests. Pull requests appreciated.
