require File.dirname(__FILE__) + '/../spec_helper'

module DatabaseCleaner
  module ActiveRecord
    describe Seeded do
      let(:connection) { double('connection') }

      before(:each) do
        connection.stub(:disable_referential_integrity).and_yield
        connection.stub(:database_cleaner_view_cache).and_return([])
        ::ActiveRecord::Base.stub(:connection).and_return(connection)

        allow(connection).to receive(:delete_table)
      end

      describe '#start' do
        it 'sends a call to the adapter to restore the database'
      end

      describe '#prepare' do
        it 'deletes data in all tables except for schema_migrations'
        it 'generates the seeds file using the seed data proc'
      end
    end
  end
end
