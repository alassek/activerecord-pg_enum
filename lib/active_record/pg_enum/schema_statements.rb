module ActiveRecord
  module PGEnum
    register :schema_statements do
      require "active_record/connection_adapters/postgresql_adapter"
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include SchemaStatements
    end

    module SchemaStatements
      # Drop an ENUM type from the database.
      def drop_enum(name, values_for_revert = nil)
        execute("DROP TYPE #{name}").tap {
          reload_type_map
        }
      end

      # Rename an existing ENUM type
      def rename_enum(name, options = {})
        to = options.fetch(:to) { raise ArgumentError, ":to is required" }
        execute("ALTER TYPE #{name} RENAME TO #{to}").tap {
          reload_type_map
        }
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
      def add_enum_value(type, value, options = {})
        before, after = options.values_at(:before, :after)
        cmd = "ALTER TYPE #{type} ADD VALUE '#{value}'"

        if before && after
          raise ArgumentError, "Cannot have both :before and :after at the same time"
        elsif before
          cmd << " BEFORE '#{before}'"
        elsif after
          cmd << " AFTER '#{after}'"
        end

        execute(cmd).tap { reload_type_map }
      end

      # Change the label of an existing ENUM value
      #
      # Options:
      #   from: The original label string
      #   to:   The desired label string
      #
      # Example:
      #
      #   rename_enum_value "foo_type", from: "quux", to: "Quux"
      #
      # Note: This feature requires PostgreSQL 10 or later
      def rename_enum_value(type, options = {})
        from = options.fetch(:from) { raise ArgumentError, ":from is required" }
        to   = options.fetch(:to)   { raise ArgumentError, ":to is required" }

        execute("ALTER TYPE #{type} RENAME VALUE '#{from}' TO '#{to}'").tap {
          reload_type_map
        }
      end
    end
  end
end
