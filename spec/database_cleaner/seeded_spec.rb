require 'spec_helper'

module DatabaseCleaner
  module ActiveRecord
    describe Seeded do
      let(:connection) { double('connection') }
      let(:adapter) {
        DatabaseCleaner::ActiveRecord::Seeded::Adapter::MYSQL.new('foo')
      }

      before(:each) do
        allow(connection).to receive(:disable_referential_integrity).and_yield
        allow(connection).to receive(:database_cleaner_view_cache).and_return([])
        allow(::ActiveRecord::Base).to receive(:connection).and_return(connection)
        allow(connection).to receive(:delete_table)
        allow(DatabaseCleaner::ActiveRecord::Seeded::Adapter::MYSQL)
          .to receive(:new).and_return(adapter)
      end

      describe '#start' do
        it 'sends a call to the adapter to inject seeds' do
          expect(adapter).to receive(:inject_seeds_from_fixtures_file)

          Seeded.new.start
        end
      end

      describe '#prepare' do
        before :each do
          allow(connection).to receive(:database_cleaner_table_cache)
            .and_return(%w[schema_migrations shoes hats])
          allow(adapter).to receive(:dump_database_to_fixtures_file)

          allow(connection).to receive(:transaction).and_yield
        end

        it 'deletes data in all tables except for schema_migrations' do
          expect(connection).to receive(:delete_table).with('shoes')
          expect(connection).to receive(:delete_table).with('hats')

          Seeded.new.prepare {}
        end

        it 'asks the adapter to dump the database' do
          expect(adapter).to receive(:dump_database_to_fixtures_file)

          Seeded.new.prepare {}
        end

        it 'calls the seed data proc in the method' do
          seed_data_spy = spy(:seed_proc)
          expect(seed_data_spy).to receive(:call)

          Seeded.new.prepare { seed_data_spy.call }
        end

        context "when the 'skip_seed_regeneration' proc has been set to something that returns true" do
          let(:file_path) { 'some/file/path' }

          before :each do
            DatabaseCleaner::ActiveRecord::Seeded.configure do |config|
              config.skip_seed_regeneration = -> { true }
              config.seeds_file_path = file_path
            end
          end

          context 'and the seeds fixture file already exists' do
            before :each do
              allow(File).to receive(:exists?)
                .with(file_path).and_return(true)
            end

            it "doesn't call the seed data proc in the method" do
              seed_data_spy = spy(:seed_proc)
              expect(seed_data_spy).not_to receive(:call)

              Seeded.new.prepare { seed_data_spy.call }
            end
          end

          context "and the seeds fixture file doesn't already exist" do
            before :each do
              allow(File).to receive(:exists?)
                .with(file_path).and_return(false)
            end

            it 'still calls the seed data proc in the method' do
              seed_data_spy = spy(:seed_proc)
              expect(seed_data_spy).to receive(:call)

              Seeded.new.prepare { seed_data_spy.call }
            end
          end
        end
      end
    end
  end
end
