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
          SELECT n.nspname AS schema, t.typname AS enum_name, array_agg(e.enumlabel ORDER BY e.enumsortorder) AS enum_value
          FROM pg_type t
          JOIN pg_enum e ON t.oid = e.enumtypid
          JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
          GROUP BY schema, enum_name
        SQL

        coltype = res.column_types["enum_value"]
        deserialize = if coltype.respond_to?(:deserialize)
          proc { |values| coltype.deserialize(values) }
        elsif coltype.respond_to?(:type_cast_from_database)
          proc { |values| coltype.type_cast_from_database(values) }
        else
          proc { |values| coltype.type_cast(values) }
        end

        public_enums, custom = res.rows.partition { |schema, _, _| schema == "public" }
        custom.map! { |schema, name, values| ["#{schema}.#{name}", values] }

        public_enums
          .map { |_, name, values| [name, values] }
          .concat(custom)
          .sort { |a, b| a.first <=> b.first }
          .each_with_object({}) { |(name, values), memo| memo[name] = deserialize.call(values) }
      end
    end
  end
end
