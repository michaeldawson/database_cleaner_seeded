require 'spec_helper'
require 'database_cleaner/active_record/seeded/configuration'

describe DatabaseCleaner::ActiveRecord::Seeded::Configuration do
  let(:config) { DatabaseCleaner::ActiveRecord::Seeded::Configuration.new }

  describe '#skip_seed_regeneration=' do
    it 'default value is nil' do
      expect(config.skip_seed_regeneration).to be_nil
    end

    it 'can set value' do
      value = Proc.new {}

      config.skip_seed_regeneration = value
      expect(config.skip_seed_regeneration).to eq(value)
    end
  end

  describe '#seeds_file_path=' do
    it "default value is 'tmp/database_cleaner_seeds.sql'" do
      expect(config.seeds_file_path).to eq('tmp/database_cleaner_seeds.sql')
    end

    it 'can set value' do
      value = 'spec/some/other/path'

      config.seeds_file_path = value
      expect(config.seeds_file_path).to eq(value)
    end
  end
end
