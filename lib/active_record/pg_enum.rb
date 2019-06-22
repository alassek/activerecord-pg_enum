require "active_support/lazy_load_hooks"
require "active_record"

ActiveSupport.on_load(:active_record) do
  require "active_record/pg_enum/helper"
  ActiveRecord::PGEnum.install Gem.loaded_specs["activerecord"].version
end

module ActiveRecord
  module PGEnum
    KNOWN_VERSIONS = %w[5.0 5.1 5.2 6.alpha].map { |v| Gem::Version.new(v) }

    class << self
      attr_reader :enabled_version
    end

    def self.install(version)
      major_minor = version.canonical_segments[0..1].join(".")
      major_minor = Gem::Version.new(major_minor)

      # Don't immediately fail if we don't yet support the current version.
      # There's at least a chance it could work.
      if !KNOWN_VERSIONS.include?(major_minor) && major_minor > KNOWN_VERSIONS.last
        major_minor = KNOWN_VERSIONS.last
        warn "[PGEnum] Current ActiveRecord version unsupported! Falling back to: #{major_minor}"
      end

      require "active_record/pg_enum/#{major_minor}/prepare_column_options"
      require "active_record/pg_enum/#{major_minor}/schema_dumper"
      require "active_record/pg_enum/postgresql_adapter"
      require "active_record/pg_enum/schema_statements"
      require "active_record/pg_enum/command_recorder"
      require "active_record/pg_enum/table_definition"

      install_column_options
      install_schema_dumper
      install_postgresql_adapter
      install_schema_statements
      install_command_recorder
      install_table_definition

      @enabled_version = major_minor
    end
  end
end
