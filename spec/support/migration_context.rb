module MigrationContext
  # Rails 5.2 moved from a unary Migrator class to
  # MigrationContext, that can be scoped to a given
  # path.
  def with_migrator(path)
    if defined?(ActiveRecord::MigrationContext)
      yield ActiveRecord::MigrationContext.new(path)
    else
      migrator  = ActiveRecord::Migrator
      old_paths = migrator.migrations_paths

      migrator.migrations_paths = [path.to_s]

      yield migrator

      migrator.migrations_paths = old_paths
    end
  end
end
