module ActiveRecord
  module PGEnum
    register :schema_dumper do
      require "active_record/schema_dumper"
      ActiveRecord::SchemaDumper.prepend SchemaDumper
    end

    module SchemaDumper
      private

      def extensions(stream)
        super
        enums(stream)
      end

      def enums(stream)
        return unless (enum_types = @connection.enum_types).any?

        stream.puts "  # These are custom enum types that must be created before they can be used in the schema definition"

        enum_types.each do |name, definition|
          stream.puts %Q{  create_enum "#{name}", #{definition}}
        end

        stream.puts
      end
    end
  end
end

