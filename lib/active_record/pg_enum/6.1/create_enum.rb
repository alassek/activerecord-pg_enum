module ActiveRecord
  module PGEnum
    register :create_enum do
      require "active_record/connection_adapters/postgresql_adapter"
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include CreateEnum
    end

    module CreateEnum
      # Create a new ENUM type, with an arbitrary number of values.
      #
      # Example:
      #
      #   create_enum("foo_type", "foo", "bar", "baz", "foo bar")
      def create_enum(name, values)
        execute("CREATE TYPE #{name} AS ENUM (#{Array(values).map { |v| "'#{v}'" }.join(", ")})").tap {
          reload_type_map
        }
      end
    end
  end
end
