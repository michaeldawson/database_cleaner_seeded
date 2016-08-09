# -----------------------------------------------------------------------------
#  Adapter for dumping and restoring seeds to the database using MYSQL.
#  Currently doesn't support connections that use passwords.
# -----------------------------------------------------------------------------

require 'database_cleaner/active_record/truncation'

module DatabaseCleaner
  module ActiveRecord
    class Seeded < Deletion # I hate this, but omitting it gives a superclass violation
      module Adapter
        class MYSQL
          IGNORE_TABLES = %w(schema_migrations)

          attr_reader :seeds_file_path

          def initialize(seeds_file_path)
            @seeds_file_path = seeds_file_path
          end

          def inject_seeds_from_fixtures_file
            `mysql --user=#{user} --host=#{host} --port=#{port} --database=#{database} < #{seeds_file_path}`
          end

          def dump_database_to_fixtures_file
            `mysqldump --user=#{user} --host=#{host} --port=#{port} --compact #{ignore_tables} --no-create-info=TRUE #{database} > #{seeds_file_path}`
          end

          private

          def configuration
            @configuration ||= ::ActiveRecord::Base.configurations["test"]
          end

          def port
            3306
          end

          def user
            @user ||= configuration["username"] || 'root'
          end

          def host
            @host ||= configuration["host"]
          end

          def database
            @database ||= configuration["database"]
          end

          def ignore_tables
            IGNORE_TABLES.map { |table| "--ignore-table=#{[database, table].join('.')}" }.join(' ')
          end
        end
      end
    end
  end
end
