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

        enum_types.each do |enum_type|
          stream.puts %Q{  create_enum "#{enum_type.first}", "#{enum_type.second.join("\", \"")}"}
        end

        stream.puts
      end

      def column_spec(column)
        type, spec = super

        if column.type == :enum
          type      = "column"
          enum_type = spec.delete(:enum_type)
          spec      = [enum_type.inspect, spec]
        end

        [type, spec]
      end

      def prepare_column_options(column)
        super.tap do |spec|
          spec[:enum_type] = column.sql_type if column.type == :enum
        end
      end

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
