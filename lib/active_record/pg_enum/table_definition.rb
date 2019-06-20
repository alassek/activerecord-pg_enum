module ActiveRecord
  module PGEnum
    def self.install_table_definition
      require "active_record/connection_adapters/postgresql_adapter"
      ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.include TableDefinition
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
