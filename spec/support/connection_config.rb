require_relative "version_matcher"

def db_config_hash
  {
    adapter: "postgresql",
    host:     ENV.fetch("PGHOST", "localhost"),
    port:     ENV.fetch("PGPORT", "5432"),
    database: ENV.fetch("TEST_DATABASE", "pg_enum_test"),
    username: ENV.fetch("TEST_USER") { ENV.fetch("USER", "pg_enum") },
    password: ENV["TEST_PASSWORD"],
    schema_search_path: 'public, custom_namespace'
  }
end

def db_config
  @db_config ||= begin
    if VersionMatcher.new("activerecord").matches?("< 6.1")
      db_config_hash
    else
      require "active_record/database_configurations"
      ActiveRecord::DatabaseConfigurations::HashConfig.new("test", "primary", db_config_hash)
    end
  end
end
