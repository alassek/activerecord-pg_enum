module ActiveRecord
  module PGEnum
    module SchemaStatements
      def create_enum(name, *values)
        execute "CREATE TYPE #{name} AS ENUM (#{values.map { |v| "'#{v}'" }.join(", ")})"
      end

      def drop_enum(name)
        execute "DROP TYPE #{name}"
      end
    end
  end
end
