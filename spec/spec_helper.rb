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
require_relative "support/connection_helpers"
require_relative "support/migration_helpers"
require_relative "support/version_matcher"
require_relative "support/version_helper"

# Normally this would be run by Rails when it boots
ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

ActiveRecord::Migration.verbose = false

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :suite do
    ActiveRecord::SchemaMigration.create_table
    FileUtils.mkdir_p spec_root / "migrations"
  end

  config.after :suite do
    FileUtils.rm_rf spec_root / "migrations"
  end

  # Create a metadata syntax for defining a version spec
  #
  # Example
  #
  #   RSpec.describe "Subject", version: ">= 6.0.0"
  #   Will only run the spec if ActiveRecord is >= 6.0.0
  config.filter_run_excluding version: VersionMatcher.new("activerecord").to_proc

  config.order = :random
  Kernel.srand config.seed
end
