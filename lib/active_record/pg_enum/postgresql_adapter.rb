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
          WHERE n.nspname = ANY (current_schemas(false))
          GROUP BY enum_name;
        SQL

        coltype = res.column_types["enum_value"]
        deserialize = if coltype.respond_to?(:deserialize)
          proc { |values| coltype.deserialize(values) }
        elsif coltype.respond_to?(:type_cast_from_database)
          proc { |values| coltype.type_cast_from_database(values) }
        else
          proc { |values| coltype.type_cast(values) }
        end

        res.rows
          .map { |name, values| [name, values] }
          .sort { |a, b| a.first <=> b.first }
          .each_with_object({}) { |(name, values), memo| memo[name] = deserialize.call(values) }
      end

      # Helper method that returns only the values of a specific ENUM types.  Uses a WeakRef as a short lived
      # cache to prevent hitting the database for every enum on startup.
      #
      # Returns an array of strings like ["foo", "bar", "baz"]
      def self.cached_enum_values
        enum_types
      end

      # Helper method to creates an ActiveRecord enum, inferring the values from the ENUM type specified.
      #
      # Can be called as `inferred_enum(foo: :foo_type)` or can accept any arguments normally accepted
      # by ActiveRecord enum for example `inferred_enum(foo: :foo_type, _prefix: 'foobar', _suffix: true)`
      #
      def inferred_enum(options)
        raise ArgumentError('inferred_enum expects a hash argument') unless options.is_a?(Hash)

        key, value = options.shift

        enum_values = PostgreSQLAdapter.cached_enum_types[value.to_s]
        enum_value_hash = enum_values.zip(enum_values).to_h
        enum({ key.to_sym => enum_value_hash, **options })
      end

    end
  end
end
