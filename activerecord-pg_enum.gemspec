# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record/pg_enum/version"

Gem::Specification.new do |spec|
  spec.name    = "activerecord-pg_enum"
  spec.version = ActiveRecord::PGEnum::VERSION
  spec.authors = ["Adam Lassek"]
  spec.email   = ["adam@doubleprime.net"]

  spec.summary  = %q{Integrate PostgreSQL's enumerated types with the Rails enum feature}
  spec.homepage = "https://github.com/alassek/activerecord-pg_enum"
  spec.license  = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/alassek/activerecord-pg_enum/issues",
    "changelog_uri"   => "https://github.com/alassek/activerecord-pg_enum/blob/master/CHANGELOG.md",
    "pgp_keys_uri"    => "https://keybase.io/alassek/pgp_keys.asc",
    "signatures_uri"  => "https://keybase.pub/alassek/gems/"
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.required_ruby_version = ">= 2.2.2"

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "pg"
  spec.add_dependency "activerecord", ">= 4.1.0"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
