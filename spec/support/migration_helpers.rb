module MigrationHelpers
  def self.included(klass)
    klass.extend ClassMethods
  end

  # The arity of load_schema is different depending on version.
  # Versions prior to 5.0 relied on global configuration, whereas
  # 5.0+ use a required argument.
  def load_schema(config, format, filename)
    ActiveRecord::Tasks::DatabaseTasks.tap do |db|
      load_schema = db.method(:load_schema)

      method_name = if load_schema.parameters.include?([:req, :configuration])
        :load_schema
      else
        :load_schema_for
      end

      db.public_send method_name, config, format, filename
      connection.send :reload_type_map
    end
  end

  # Rails 5.2 moved from a unary Migrator class to
  # MigrationContext, that can be scoped to a given
  # path.
  def with_migrator
    if defined?(ActiveRecord::MigrationContext)
      yield ActiveRecord::MigrationContext.new(migration_path)
    else
      migrator  = ActiveRecord::Migrator
      old_paths = migrator.migrations_paths

      migrator.migrations_paths = [migration_path.to_s]

      yield migrator

      migrator.migrations_paths = old_paths
    end
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
