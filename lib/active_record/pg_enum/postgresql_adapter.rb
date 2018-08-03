module ActiveRecord
  module PGEnum
    module PostgreSQLAdapter
      def enum_types
        res = exec_query(<<-SQL.strip_heredoc, "SCHEMA").cast_values
          SELECT t.typname AS enum_name, string_agg(e.enumlabel, ' ' ORDER BY e.enumsortorder) AS enum_value
          FROM pg_type t
          JOIN pg_enum e ON t.oid = e.enumtypid
          JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
          WHERE n.nspname = 'public'
          GROUP BY enum_name
        SQL

        res.map do |(name, values)|
          [name, values.split(" ")]
        end
      end
    end
  end
end
