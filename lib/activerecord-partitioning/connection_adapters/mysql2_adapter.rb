require 'active_record/connection_adapters/mysql2_adapter'

module ActiveRecord::Partitioning
  module ConnectionAdapters
    module Mysql2Adapter
      # Yields the partitioning information for the given table if it is partitioned.
      def partition(name, &block)
        create_table_statement = select_one("SHOW CREATE TABLE #{quote_table_name(name)}")['Create Table']
        return unless create_table_statement =~ %r{/\*!50100\s([^\*]+)\s\*/}
        yield($1.gsub(/(\s*\r?\n\s*)+/, ' '))
      end

      # Alters the existing table so that it is partitioned according to the specified scheme.
      def partition_table(name, scheme)
        raise InvalidSchemeError, scheme if scheme.blank?
        execute("ALTER TABLE #{quote_table_name(name)} #{scheme}")
      end

      # Removes all partitions from the given table
      def unpartition_table(name)
        execute("ALTER TABLE #{quote_table_name(name)} REMOVE PARTITIONING")
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  class ActiveRecord::ConnectionAdapters::Mysql2Adapter
    include ActiveRecord::Partitioning::ConnectionAdapters::Mysql2Adapter
  end
end
