module ActiveRecord
  # Declare an enum attribute where the values map to strings enforced by PostgreSQL's
  # enumerated types.
  #
  #   class Conversation < ActiveRecord::Base
  #     include ActiveRecord::PGEnum(status: %i[active archived])
  #   end
  #
  # This is merely a wrapper over traditional enum syntax so that you can define
  # string-based enums with an array of values.
  def self.PGEnum(**definitions)
    values = definitions.values.map do |value|
      if value.is_a? Array
        keys   = value.map(&:to_sym)
        values = value.map(&:to_s)

        Hash[keys.zip(values)]
      else
        value
      end
    end

    Module.new do
      define_singleton_method(:inspect) { %{ActiveRecord::PGEnum(#{definitions.keys.join(" ")})} }

      define_singleton_method :included do |klass|
        klass.enum Hash[definitions.keys.zip(values)]
      end
    end
  end
end
