# Patch to Arel::Visitors::Visitor specific to Rails 4.1
# Rails 4.2 doesn't require a patch, Rails 5.0 requires a different patch

module Arel
  module Visitors
    class DepthFirst < Arel::Visitors::Visitor
      alias :visit_Integer :terminal
    end

    class Dot < Arel::Visitors::Visitor
      alias :visit_Integer :visit_String
    end

    class ToSql < Arel::Visitors::Visitor
      alias :visit_Integer :literal
    end
  end
end

