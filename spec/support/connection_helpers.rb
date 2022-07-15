module ConnectionHelpers
  def enum_types
    type_list = connection.enum_types

    if type_list.is_a?(Array)
      type_list = type_list.sort { |(a, _), (b, _)| a <=> b }
      type_list = type_list.each_with_object({}) do |(enum_type, values), list|
        list[enum_type] = values.split(",")
      end
    end

    type_list
  end
end

RSpec.configure do |config|
  config.include ConnectionHelpers
end
