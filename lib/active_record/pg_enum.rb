require "active_record"
require "active_record/connection_adapters/postgresql/schema_dumper"
require "active_record/connection_adapters/postgresql/schema_statements"
require "active_record/connection_adapters/postgresql_adapter"
require "active_support/lazy_load_hooks"

ActiveSupport.on_load(:active_record) do
  require "active_record/pg_enum/postgresql_adapter"
  require "active_record/pg_enum/schema_dumper"
  require "active_record/pg_enum/schema_statements"

  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.merge!(enum: { name: "enum" })

  ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.prepend ActiveRecord::PGEnum::SchemaDumper

  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include ActiveRecord::PGEnum::PostgreSQLAdapter
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include ActiveRecord::PGEnum::SchemaStatements
end
