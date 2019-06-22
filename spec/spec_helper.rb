require "bundler/setup"
require "pry"
require "active_record/pg_enum"
require "active_support/core_ext/string/strip"

def spec_root
  Pathname.new(File.expand_path(__dir__))
end

require_relative "support/connection"
require_relative "support/table_helpers"
require_relative "support/rails_env"
require_relative "support/migration_context"
require_relative "support/version_matcher"

# Normally this would be run by Rails when it boots
ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

ActiveRecord::Migration.verbose = false

RSpec.configure do |config|
  config.include TableHelpers
  config.include MigrationContext

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :suite do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute %Q{CREATE TYPE foo_type AS ENUM ('bar', 'baz')}
      conn.execute <<-SQL.strip_heredoc
        CREATE TABLE test_table (
          id serial PRIMARY KEY,
          foo foo_type NOT NULL
        )
      SQL
    end

    FileUtils.mkdir_p spec_root / "migrations"
  end

  config.after :suite do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute %Q{DROP TABLE test_table}
      conn.execute %Q{DROP TYPE foo_type}
    end

    FileUtils.rm_rf spec_root / "migrations"
  end

  # Create a metadata syntax for defining a version spec
  #
  # Example
  #
  #   RSpec.describe "Subject", version: ">= 6.0.0"
  #   Will only run the spec if ActiveRecord is >= 6.0.0
  config.around(:each) do |example|
    example.run if VersionMatcher.new("activerecord").matches?(example)
  end
end
