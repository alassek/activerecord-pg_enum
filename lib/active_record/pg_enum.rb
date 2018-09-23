require "active_record"
require "active_record/connection_adapters/postgresql/schema_dumper"
require "active_record/connection_adapters/postgresql/schema_statements"
require "active_record/connection_adapters/postgresql_adapter"
require "active_support/lazy_load_hooks"

ActiveSupport.on_load(:active_record) do
  require "active_record/pg_enum/command_recorder"
  require "active_record/pg_enum/postgresql_adapter"
  require "active_record/pg_enum/schema_dumper"
  require "active_record/pg_enum/schema_statements"
  require "active_record/pg_enum/helper"

  ar_version = Gem.loaded_specs["activerecord"].version

  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.merge!(enum: { name: "enum" })

  if ar_version >= Gem::Version.new("5.2.0")
    ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.prepend ActiveRecord::PGEnum::SchemaDumper
  end

  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include ActiveRecord::PGEnum::PostgreSQLAdapter
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include ActiveRecord::PGEnum::SchemaStatements
  ActiveRecord::Migration::CommandRecorder.include ActiveRecord::PGEnum::CommandRecorder
end
