require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "appraisal"
require "pry"

if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  task :default => :appraisal
else
  task :default => :spec
end

task :connection do
  require "active_record"
  require_relative "spec/support/connection_config"

  config = db_config_hash.except(:database)

  if ActiveRecord.constants.include?(:DatabaseConfigurations)
    config = ActiveRecord::DatabaseConfigurations::HashConfig.new("test", "primary", config)
  end

  ActiveRecord::Base.establish_connection(config)
end

namespace :spec do
  RSpec::Core::RakeTask.new(:run)

  desc "Setup the Database for testing"
  task setup: [:connection] do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.create_database ENV.fetch("TEST_DATABASE", "pg_enum_test"), owner: ENV.fetch("TEST_USER") { ENV.fetch("USER", "pg_enum") }
    end
  end

  desc "Discard the test database"
  task teardown: [:connection] do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.drop_database ENV.fetch("TEST_DATABASE", "pg_enum_test")
    end
  end

  task reset: [:teardown, :setup]
end

task spec: %w[spec:setup spec:run spec:teardown]
