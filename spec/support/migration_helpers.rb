module MigrationHelpers
  def self.included(klass)
    klass.extend ClassMethods
  end

  def db_tasks
    ActiveRecord::Tasks::DatabaseTasks
  end

  # Rails 5.2 moved from a unary Migrator class to
  # MigrationContext, that can be scoped to a given
  # path.
  #
  # Rails 6.0 requires the schema migration object
  # as an argument.
  def migration_context
    klass = ActiveRecord::MigrationContext

    case klass.instance_method(:initialize).arity
    when 1
      klass.new(migration_path)
    else
      klass.new(migration_path, schema_migration)
    end
  end

  def legacy_migrator
    migrator  = ActiveRecord::Migrator
    old_paths = migrator.migrations_paths

    migrator.migrations_paths = [migration_path.to_s]

    yield migrator

    migrator.migrations_paths = old_paths
  end

  # The base class for migrations moves around a lot
  def migration_class
    if defined?(ActiveRecord::Migration::Compatibility)
      "ActiveRecord::Migration[#{ActiveRecord::PGEnum.enabled_version}]"
    else
      "ActiveRecord::Migration"
    end
  end

  def migration_filename(class_name, version)
    "%03d_#{class_name.to_s.underscore}.rb" % version
  end

  def migration_path
    spec_root / "migrations"
  end

  def schema_migration
    conn = ActiveRecord::Base.connection

    if conn.respond_to?(:schema_migration)
      conn.schema_migration
    else
      ActiveRecord::SchemaMigration
    end
  end

  module ClassMethods
    def with_migration(class_name, version, body)
      if public_instance_methods.include?("migration_#{version}".to_sym)
        raise ArgumentError, "Migration version #{version} already defined!"
      end

      indented_body = body.to_s.strip_heredoc
      indented_body = indented_body.each_line.map { |str| str.prepend("  ") }.join

      let("migration_#{version}") { migration_path / migration_filename(class_name, version) }

      before :each do
        full_pathname = send "migration_#{version}"

        File.open(full_pathname, "w+") do |migration|
          migration.write(<<-EOF)
class #{class_name} < #{migration_class}
#{indented_body}
end
          EOF
        end
      end

      after { File.delete send("migration_#{version}") }
    end
  end
end

RSpec.configure do |config|
  config.include MigrationHelpers
end
