require "active_record"
require_relative "connection_config"

ActiveRecord::Base.establish_connection(db_config)
