module ActiveRecord
  module PGEnum
    module ColumnDumper
      def column_spec(column)
        if column.type == :enum
          return ["column", [column.sql_type.inspect, prepare_column_options(column)]]
        end

        super
      end
    end
  end
end
