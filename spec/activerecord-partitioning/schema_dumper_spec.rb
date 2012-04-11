require 'spec_helper'

describe ActiveRecord::Partitioning::SchemaDumper do
  let(:connection) do
    double(:connection)
  end

  subject do
    double(:dumper).tap do |dumper|
      # ActiveRecord::SchemaDumper uses an instance variable and provides no accessor for this:
      dumper.instance_variable_set(:@connection, connection)

      # Imbue the mock object with the ActiveRecord::SchemaDumper behaviour!
      class << dumper
        def table(name, stream) ; stream ; end
        include ActiveRecord::Partitioning::SchemaDumper
      end
    end
  end

  context '#table' do
    let(:stream) do
      double(:stream)
    end

    before(:each) do
      subject.should_receive(:table_without_partitioning).with('table', stream).and_return('used stream')
    end

    it 'does not dump partitions for a non-partitioned table' do
      connection.should_receive(:partition).with('table')
      stream.should_receive(:puts).never
      subject.table('table', stream).should == stream
    end

    it 'dumps the partitions as ALTER TABLE statements' do
      connection.should_receive(:partition).with('table').and_yield('partitioned')
      stream.should_receive(:puts).with(%Q{  partition_table("table", "partitioned")})
      stream.should_receive(:puts).with(no_args)
      subject.table('table', stream).should == stream
    end
  end
end
