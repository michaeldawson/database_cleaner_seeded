# -----------------------------------------------------------------------------
#  Custom database cleaner strategy to restore the database to a seeded state
#  for integration tests. Truncate the database, then execute a restore of
#  seeds using the DBMS.
# -----------------------------------------------------------------------------

require 'database_cleaner/active_record/deletion'
require 'database_cleaner/active_record/seeded/adapter/mysql'

module DatabaseCleaner
  module ActiveRecord
    class Seeded < Deletion
      def start
        adapter.inject_seeds_from_fixtures_file
      end

      def prepare(&seed_data_proc)
        generate_seeds(seed_data_proc) if regenerate_seeds?
        clean
      end

      private

      def adapter
        @adapter ||= Adapter::MYSQL.new(seeds_file_path)
      end

      def generate_seeds(seed_data_proc)
        ::ActiveRecord::Base.transaction { seed_data_proc.call }
        adapter.dump_database_to_fixtures_file
      end

      def regenerate_seeds?
        # raise "The option for 'regenerate_seeds' must be a Proc" if config.regenerate_seeds && !config.regenerate_seeds.respond_to?(:call)
        # regenerate_seeds_proc = config.regenerate_seeds.call if config.regenerate_seeds
        # no_seed_file_present = File.exist?(seeds_file_path)
        #
        # config.regenerate_seeds ?  : true
        !! ENV['RESEED']
      end

      def seeds_file_path
        'spec/fixtures/feature_seeds.sql'
      end
    end
  end
end

module DatabaseCleaner
  class << self
    def prepare_with(strategy, &block)
      connections.each do |connection|
        connection.strategy = strategy
        connection.strategy.prepare(&block)
      end
    end
  end
end
