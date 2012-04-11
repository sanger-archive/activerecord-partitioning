require 'spec_helper'
require 'activerecord-partitioning/connection_adapters/mysql2_adapter'

describe ActiveRecord::Partitioning::ConnectionAdapters::Mysql2Adapter do
  subject do
    double(:connection).tap do |connection|
      class << connection
        def quote_table_name(name) ; "`#{name}`" ; end
        include ActiveRecord::Partitioning::ConnectionAdapters::Mysql2Adapter
      end
    end
  end

  context '#partition' do
    let(:callback) { double(:callback) }

    after(:each) do
      subject.partition('table', &callback.method(:call))
    end

    it 'does not yield if the table is not partitioned' do
      subject.should_receive(:select_one).with('SHOW CREATE TABLE `table`').and_return(
        'Create Table' => %q{CREATE TABLE table(id INT)}
      )
      callback.should_receive(:call).never
    end

    it 'yields the partitioning statement for partitioned tables' do
      subject.should_receive(:select_one).with('SHOW CREATE TABLE `table`').and_return(
        'Create Table' => %q{CREATE TABLE table(id INT) /*!50100 partitioning */}
      )
      callback.should_receive(:call).with('partitioning')
    end

    it 'yields the partitioning statement regardless of what line it appears on' do
      subject.should_receive(:select_one).with('SHOW CREATE TABLE `table`').and_return(
        'Create Table' => %q{
          CREATE TABLE table(id INT)
          /*!50100 partitioning */
        }
      )
      callback.should_receive(:call).with('partitioning')
    end

    it 'collapses multiline partitioning schemes into a single line' do
      subject.should_receive(:select_one).with('SHOW CREATE TABLE `table`').and_return(
        'Create Table' => %q{
          CREATE TABLE table(id INT)
          /*!50100 partitioning
          scheme */
        }
      )
      callback.should_receive(:call).with('partitioning scheme')
    end
  end

  context '#partition_table' do
    [ '', ' ', nil ].each do |blank_value|
      it "raises an error if the partition scheme is #{blank_value.inspect}" do
        expect { subject.partition_table('table', blank_value) }.to raise_error(ActiveRecord::Partitioning::InvalidSchemeError)
      end
    end

    it 'performs an ALTER TABLE to add the partitioning schema' do
      subject.should_receive(:execute).with('ALTER TABLE `table` scheme')
      subject.partition_table('table', 'scheme')
    end
  end
end
