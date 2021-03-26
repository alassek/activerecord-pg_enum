require "active_record/pg_enum/4.2/table_definition"

module ActiveRecord
  module PGEnum
    module TableDefinition
      # Create an enum column inside a TableDefinition
      #
      # Example:
      #
      #   create_table :orders do |t|
      #     t.enum :status, as: "status_type"
      #   end
      def enum(name, as:, **options)
        column(name, as, **options)
      end
    end
  end
end
