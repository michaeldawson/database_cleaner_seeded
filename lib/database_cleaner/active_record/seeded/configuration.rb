module DatabaseCleaner
  module ActiveRecord
    class Seeded
      class Configuration
        DEFAULT_SEEDS_FILE_PATH = 'tmp/database_cleaner_seeds.sql'

        attr_accessor :skip_seed_regeneration, :seeds_file_path

        def initialize
          @seeds_file_path = DEFAULT_SEEDS_FILE_PATH
        end
      end
    end
  end
end
