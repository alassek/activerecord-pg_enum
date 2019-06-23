module ActiveRecord
  module PGEnum
    register :migration_keys do
      require "active_record/connection_adapters/postgresql_adapter"
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend MigrationKeys
    end

    module MigrationKeys
      def migration_keys
        super + [:as]
      end
    end
  end
end
