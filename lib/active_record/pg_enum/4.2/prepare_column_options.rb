module ActiveRecord
  module PGEnum
    def self.install_column_options
      require "active_record/connection_adapters/postgresql_adapter"
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend PrepareColumnOptions
    end

    module PrepareColumnOptions
      def prepare_column_options(column, types)
        super.tap do |spec|
          if column.type == :enum
            spec[:as] = column.sql_type
          end
        end
      end
    end
  end
end
