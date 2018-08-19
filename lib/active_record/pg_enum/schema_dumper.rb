module ActiveRecord
  module PGEnum
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
          stream.puts %Q{  create_enum "#{name}", %w[#{definition.join(" ")}]"}
        end

        stream.puts
      end

      # Gathers the arguments needed for the column line inside the create_table block.
      def column_spec(column)
        if column.type == :enum
          ["column", [column.sql_type.inspect, prepare_column_options(column)]]
        else
          super
        end
      end

      # Takes a column specification in Object form and serializes it into a String.
      def format_colspec(colspec)
        case colspec
        when String
          colspec
        when Array
          colspec.map { |value| format_colspec(value) }.select(&:present?).join(", ")
        else
          super
        end
      end
    end
  end
end
