module ActiveRecord
  module PGEnum
    register :postgresql_adapter do
      require "active_record/connection_adapters/postgresql_adapter"
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include PostgreSQLAdapter
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.merge!(enum: { name: "enum" })
    end

    module PostgreSQLAdapter
      # Helper method used by the monkeypatch internals. Provides a hash of ENUM types as they exist currently.
      #
      # Example:
      #
      #   { "foo_type" => ["foo", "bar", "baz"] }
      def enum_types
        res = exec_query(<<-SQL.strip_heredoc, "SCHEMA")
          SELECT t.typname AS enum_name, array_agg(e.enumlabel ORDER BY e.enumsortorder) AS enum_value
          FROM pg_type t
          JOIN pg_enum e ON t.oid = e.enumtypid
          JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
          WHERE n.nspname = 'public'
          GROUP BY enum_name
        SQL

        coltype = res.column_types["enum_value"]
        deserialize = if coltype.respond_to?(:deserialize)
          proc { |values| coltype.deserialize(values) }
        elsif coltype.respond_to?(:type_cast_from_database)
          proc { |values| coltype.type_cast_from_database(values) }
        else
          proc { |values| coltype.type_cast(values) }
        end

        res.rows.inject({}) do |memo, (name, values)|
          memo[name] = deserialize.call(values)
          memo
        end
      end
    end
  end
end
