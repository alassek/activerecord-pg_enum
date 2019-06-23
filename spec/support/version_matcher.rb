class VersionMatcher
  attr_reader :spec

  def initialize(spec)
    @spec = Gem.loaded_specs[spec]
  end

  def matches?(example)
    return true unless (version = example.metadata[:version])
    requirement(version).satisfied_by? spec.version
  end

  def when(version)
    return unless block_given?

    if requirement(version).satisfied_by? spec.version
      yield
    end
  end

  private

  def requirement(version)
    return version unless version.is_a?(String)
    Gem::Requirement.create version.split(", ")
  end
end
