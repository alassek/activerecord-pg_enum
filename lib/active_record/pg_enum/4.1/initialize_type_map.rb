require "active_record/connection_adapters/postgresql_adapter"

module ActiveRecord
  module PGEnum
    register :type_map do
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend InitializeTypeMap
    end

    module InitializeTypeMap
      private

      def initialize_type_map(type_map)
        super

        adapter = ConnectionAdapters::PostgreSQLAdapter

        adapter::OID.register_type "enum", adapter::OID::Enum.new

        execute("SELECT t.oid, t.typname, t.typtype FROM pg_type as t WHERE t.typtype = 'e'", "SCHEMA").each do |row|
          adapter::OID.alias_type row["typname"], "enum"
        end
      end
    end
  end

  module ConnectionAdapters
    class PostgreSQLAdapter
      module OID
        class Enum < Type
          def type
            :enum
          end

          def type_cast(value)
            value
          end
        end
      end
    end
  end
end
