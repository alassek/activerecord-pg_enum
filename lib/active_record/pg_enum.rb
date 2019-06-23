require "active_support/lazy_load_hooks"
require "active_record"

ActiveSupport.on_load(:active_record) do
  require "active_record/pg_enum/helper"
  ActiveRecord::PGEnum.install Gem.loaded_specs["activerecord"].version
end

module ActiveRecord
  module PGEnum
    KNOWN_VERSIONS = %w[4.2 5.0 5.1 5.2 6.0].map { |v| Gem::Version.new(v) }

    class << self
      attr_reader :enabled_version

      def install(version)
        @enabled_version = approximate_version(version)

        # Don't immediately fail if we don't yet support the current version.
        # There's at least a chance it could work.
        if !KNOWN_VERSIONS.include?(enabled_version) && enabled_version > KNOWN_VERSIONS.last
          @enabled_version = KNOWN_VERSIONS.last
          warn "[PGEnum] Current ActiveRecord version unsupported! Falling back to: #{enabled_version}"
        end

        initialize!
      end

      def register(patch, &block)
        monkeypatches[patch] = block
      end

      private

      def monkeypatches
        @patches ||= {}
      end

      def initialize!
        require "active_record/pg_enum/command_recorder"
        require "active_record/pg_enum/postgresql_adapter"
        require "active_record/pg_enum/schema_statements"

        Dir[File.join(__dir__, "pg_enum", enabled_version.to_s, "*.rb")].each { |file| require file }
        monkeypatches.keys.each { |patch| monkeypatches.delete(patch).call }
      end

      def approximate_version(version)
        segments = version.respond_to?(:canonical_segments) ? version.canonical_segments : version.segments

        segments.pop     while segments.any? { |s| String === s }
        segments.pop     while segments.size > 2
        segments.push(0) while segments.size < 2

        Gem::Version.new segments.join(".")
      end
    end
  end
end
