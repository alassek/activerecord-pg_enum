module ActiveRecord
  module PGEnum
    register :table_definition do
      require "active_record/connection_adapters/postgresql_adapter"
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::TableDefinition.include TableDefinition
    end

    module TableDefinition
      # Create an enum column inside a TableDefinition
      #
      # Example:
      #
      #   create_table :orders do |t|
      #     t.enum :status, as: "status_type"
      #   end
      def enum(name, as:, **options)
        column(name, as, options)
      end
    end
  end
end
