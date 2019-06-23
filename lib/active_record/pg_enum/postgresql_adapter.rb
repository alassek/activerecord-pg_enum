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
          SELECT t.typname AS enum_name, string_agg(e.enumlabel, ' ' ORDER BY e.enumsortorder) AS enum_value
          FROM pg_type t
          JOIN pg_enum e ON t.oid = e.enumtypid
          JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
          WHERE n.nspname = 'public'
          GROUP BY enum_name
        SQL

        if res.respond_to?(:cast_values)
          res = res.cast_values
        else
          res = res.rows
        end

        res.inject({}) do |memo, (name, values)|
          memo[name] = values.split(" ")
          memo
        end
      end
    end
  end
end
