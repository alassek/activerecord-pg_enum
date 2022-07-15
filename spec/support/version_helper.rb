module VersionHelper
  def version
    @version ||= VersionMatcher.new("activerecord")
  end
end

RSpec.configure do |config|
  config.include VersionHelper
end
