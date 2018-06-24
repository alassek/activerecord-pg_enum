unless defined?(Rails)
  require "active_support/string_inquirer"

  module Rails
    def self.env
      ActiveSupport::StringInquirer.new("test")
    end
  end
end
