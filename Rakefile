require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "appraisal"

if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  task :default => :appraisal
else
  task :default => :spec
end

task :connection do
  require "active_record"
  require_relative "spec/support/connection_config"
  ActiveRecord::Base.establish_connection db_config.merge(database: 'template1')
end

namespace :spec do
  RSpec::Core::RakeTask.new(:run)

  desc "Setup the Database for testing"
  task setup: [:connection] do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.create_database db_config[:database], owner: db_config[:username]
    end
  end

  desc "Discard the test database"
  task teardown: [:connection] do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.drop_database db_config[:database]
    end
  end
end

task spec: %w[spec:setup spec:run spec:teardown]
