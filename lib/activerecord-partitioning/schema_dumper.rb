require 'active_support/concern'

module ActiveRecord::Partitioning
  module SchemaDumper
    extend ActiveSupport::Concern

    included do
      alias_method_chain(:table, :partitioning)
    end

    # Override the standard table dumping behaviour to include the partition dumping
    def table_with_partitioning(table, stream)
      table_without_partitioning(table, stream)
      dump_primary_keys_of(table, stream) # some partitioned tables have composite primary keys
      dump_partitions_of(table, stream)
      stream
    end

    # Dump the necessary Ruby code to partition the given table if it is partitioned.
    def dump_partitions_of(table, stream)
      @connection.partition(table) do |partitioning_scheme|
        stream.puts "  partition_table(#{table.inspect}, #{partitioning_scheme.inspect})"
        stream.puts
      end
    end

    # Dump the primary keys if they are composite
    def dump_primary_keys_of(table, stream)
      keys = @connection.primary_keys(table)
      if keys.length > 1
        stream.puts "  set_primary_keys(#{table.inspect}, [#{keys.map(&:inspect).join(", ")}])"
        stream.puts
      end
    end

    private :dump_partitions_of, :dump_primary_keys_of
  end
end

# Uurggh. Have to include all of these for ActiveRecord::SchemaDumper
require 'active_record'
require 'active_record/base'
require 'active_record/schema_dumper'

class ActiveRecord::SchemaDumper
  include ActiveRecord::Partitioning::SchemaDumper
end
