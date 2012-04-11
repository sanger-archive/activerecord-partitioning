require "activerecord-partitioning/version"

module ActiveRecord
  module Partitioning
    class InvalidSchemeError < StandardError ; end
    require "activerecord-partitioning/schema_dumper"
    require "activerecord-partitioning/connection_adapters/mysql2_adapter"
  end
end
