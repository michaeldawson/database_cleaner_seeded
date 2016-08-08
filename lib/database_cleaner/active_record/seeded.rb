# -----------------------------------------------------------------------------
#  Custom database cleaner strategy to restore the database to a seeded state
#  for integration tests. Truncate the database, then execute a restore of
#  seeds using the DBMS.
# -----------------------------------------------------------------------------

require 'database_cleaner/active_record/truncation'

module DatabaseCleaner::ActiveRecord
  class Seeded < Truncation
    include ::DatabaseCleaner::Generic::Base

    alias_method :truncate, :clean

    def start
      truncate                                       # First, truncate the database using the inherited `clean` method
      adapter.restore_database_from_fixtures_file    # Then insert data from the fixtures file
    end

    # Override the clean method to a no-op, as we
    # want to truncate and restore on start instead
    def clean
    end

    def prepare(&seed_data_proc)
      seed_data_proc.call

      adapter.dump_database_to_fixtures_file

      truncate
    end

    def adapter
      @adapter ||= Adapters::MYSQL.new
    end
  end
end
