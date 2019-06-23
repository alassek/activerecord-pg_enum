require "active_record/pg_enum/4.2/schema_dumper"

module ActiveRecord
  module PGEnum
    register :schema_dumper do
      require "active_record/connection_adapters/postgresql/schema_dumper"
      ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.prepend SchemaDumper
    end
  end
end
