module VersionHelper
  def version
    @version ||= VersionMatcher.new("activerecord")
  end
end
