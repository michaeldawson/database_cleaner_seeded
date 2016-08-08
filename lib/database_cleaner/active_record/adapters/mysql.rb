# -----------------------------------------------------------------------------
#  Adapter for dumping and restoring seeds to the database using MYSQL.
#  Currently doesn't support connections that use passwords.
# -----------------------------------------------------------------------------

class DatabaseCleaner::ActiveRecord::Seeded::Adapters::MYSQL
  SEEDS_FILE_PATH = Rails.root.join('spec', 'fixtures', 'feature_seeds.sql')
  IGNORED_TABLES = %w(schema_migrations)

  private

  def configuration
    @configuration ||= ActiveRecord::Base.configurations["test"]
  end

  def port
    3306
  end

  def restore_database_from_fixtures_file
    `mysql --user=#{configuration["username"]} --host=#{configuration["host"]} --port=#{port} --database=#{configuration["database"]} < #{SEEDS_FILE_PATH}`
  end

  def dump_database_to_fixtures_file
    `mysqldump --user=#{configuration["username"]} --host=#{configuration["host"]} --port=#{port} --compact --ignore-table=#{ignored_tables} --no-create-info=TRUE #{configuration["database"]} > #{SEEDS_FILE_PATH}`
  end

  def ignored_tables
    IGNORED_TABLES.map { |table| [configuration["database"], table].join('.') }
  end
end
