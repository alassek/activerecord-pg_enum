require "active_record"

def db_config
  {
    adapter: "postgresql",
    database: ENV.fetch("TEST_DATABASE", "pg_enum_test"),
    username: ENV.fetch("TEST_USER") { ENV.fetch("USER", "pg_enum") },
    password: ENV["TEST_PASSWORD"]
  }
end

ActiveRecord::Base.establish_connection(db_config)
