require "active_record/connection_adapters/postgresql_adapter"

module ActiveRecord
  module PGEnum
    register :simplified_type do
      ConnectionAdapters::PostgreSQLColumn.prepend SimplifiedType
    end

    module SimplifiedType
      private

      def simplified_type(sql_type)
        if ConnectionAdapters::PostgreSQLAdapter::OID::NAMES[sql_type].type == :enum
          :enum
        else
          super
        end
      end
    end
  end
end
