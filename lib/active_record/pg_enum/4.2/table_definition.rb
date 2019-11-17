require "active_record/pg_enum/4.1/table_definition"

module ActiveRecord
  module PGEnum
    register :table_definition do
      require "active_record/connection_adapters/postgresql_adapter"
      ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.include TableDefinition
      ActiveRecord::ConnectionAdapters::PostgreSQL::Table.include TableDefinition
    end
  end
end
