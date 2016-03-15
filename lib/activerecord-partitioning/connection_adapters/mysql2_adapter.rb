require 'active_record/connection_adapters/mysql2_adapter'

module ActiveRecord::Partitioning
  module ConnectionAdapters
    module Mysql2Adapter

      # special methods to handle composite primary keys, which we have on some partitioned tables
      def primary_keys(name)
        keys = []
        result = execute("DESCRIBE #{quote_table_name(name)}", 'SCHEMA')
        result.each(:symbolize_keys => true, :as => :hash) do |row|
          keys << row[:Field] if row[:Key] == "PRI"
        end
        keys
      end

      def set_primary_keys(name, keys)
        execute("ALTER TABLE #{quote_table_name(name)} ADD PRIMARY KEY (#{keys.join(", ")})")

        # if the key is named id, assume it is an integer and must be auto-incremented. Can only set this after the primary key.
        id = keys.find{|key| key.downcase == "id"}
        if id.present?
          execute("ALTER TABLE #{quote_table_name(name)} MODIFY COLUMN #{id} int NOT NULL AUTO_INCREMENT")
        end
      end

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
