require "active_record/pg_enum/5.0/prepare_column_options"

module ActiveRecord
  module PGEnum
    def self.install_column_options
      require "active_record/connection_adapters/postgresql/schema_dumper"
      ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.prepend PrepareColumnOptions
    end
  end
end
