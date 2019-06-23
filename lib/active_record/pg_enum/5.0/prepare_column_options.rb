module ActiveRecord
  module PGEnum
    register :column_options do
      require "active_record/connection_adapters/postgresql/schema_dumper"
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend PrepareColumnOptions
    end

    module PrepareColumnOptions
      def prepare_column_options(column)
        spec = super
        spec[:as] = column.sql_type.inspect if column.type == :enum
        spec
      end
    end
  end
end
