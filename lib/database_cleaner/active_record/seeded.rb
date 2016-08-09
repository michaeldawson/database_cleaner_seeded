# -----------------------------------------------------------------------------
#  Custom database cleaner strategy to restore the database to a seeded state
#  for integration tests. Truncate the database, then execute a restore of
#  seeds using the DBMS.
# -----------------------------------------------------------------------------

require 'database_cleaner/active_record/deletion'
require 'database_cleaner/active_record/seeded/adapter/mysql'
require 'database_cleaner/active_record/seeded/configuration'

module DatabaseCleaner
  module ActiveRecord
    class Seeded < Deletion
      class << self
        attr_writer :configuration

        def configure
          yield(configuration)
        end

        def configuration
          @configuration ||= Configuration.new
        end
      end

      def start
        adapter.inject_seeds_from_fixtures_file
      end

      def prepare(&seed_data_proc)
        generate_seeds(seed_data_proc) unless skip_seeds_generation?
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

      # If the user has configured the gem to skip seeds generation, return
      # true, but only if we already have a seeds file that we can use.
      def skip_seeds_generation?
        raise "The option for 'skip_seed_regeneration' must be a Proc" if skip_seeds_proc && !skip_seeds_proc.respond_to?(:call)
        skip_seeds_proc.try(:call) && File.exists?(seeds_file_path)
      end

      def seeds_file_path
        @seeds_file_path ||= self.class.configuration.seeds_file_path
      end

      def skip_seeds_proc
        @skip_seeds_proc ||= self.class.configuration.skip_seed_regeneration
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
