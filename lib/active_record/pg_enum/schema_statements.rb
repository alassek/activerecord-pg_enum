module ActiveRecord
  module PGEnum
    def self.install_schema_statements
      require "active_record/connection_adapters/postgresql/schema_statements"
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include SchemaStatements
    end

    module SchemaStatements
      # Create a new ENUM type, with an arbitrary number of values.
      #
      # Example:
      #
      #   create_enum("foo_type", "foo", "bar", "baz")
      def create_enum(name, values)
        execute "CREATE TYPE #{name} AS ENUM (#{Array(values).map { |v| "'#{v}'" }.join(", ")})"
      end

      # Drop an ENUM type from the database.
      def drop_enum(name, values_for_revert = nil)
        execute "DROP TYPE #{name}"
      end

      # Add a new value to an existing ENUM type.
      # Only one value at a time is supported by PostgreSQL.
      #
      # Options:
      #   before: add value BEFORE the given value
      #   after:  add value AFTER the given value
      #
      # Example:
      #
      #   add_enum_value("foo_type", "quux", before: "bar")
      def add_enum_value(type, value, before: nil, after: nil)
        cmd = "ALTER TYPE #{type} ADD VALUE '#{value}'"

        if before && after
          raise ArgumentError, "Cannot have both :before and :after at the same time"
        elsif before
          cmd << " BEFORE '#{before}'"
        elsif after
          cmd << " AFTER '#{after}'"
        end

        execute cmd
      end
    end
  end
end
