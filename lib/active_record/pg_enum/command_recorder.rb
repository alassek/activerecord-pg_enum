module ActiveRecord
  module PGEnum
    register :command_recorder do
      require "active_record/migration/command_recorder"
      ActiveRecord::Migration::CommandRecorder.include CommandRecorder
    end

    # ActiveRecord::Migration::CommandRecorder is a class used by reversible migrations.
    # It captures the forward migration commands and translates them into their inverse
    # by way of some simple metaprogramming.
    #
    # The Migrator class uses CommandRecorder during the reverse migration instead of
    # the connection object. Forward migration calls are translated to their inverse
    # where possible, and then forwarded to the connetion. Irreversible migrations
    # raise an exception.
    #
    # Known schema statement methods are metaprogrammed into an inverse method like so:
    #
    #   create_table => invert_create_table
    #
    # which returns:
    #
    #   [:drop_table, args.first]
    module CommandRecorder
      def create_enum(*args, &block)
        record(:create_enum, args, &block)
      end

      def drop_enum(*args, &block)
        record(:drop_enum, args, &block)
      end

      def add_enum_value(*args, &block)
        record(:add_enum_value, args, &block)
      end

      def rename_enum(name, options = {})
        record(:rename_enum, [name, options])
      end

      def rename_enum_value(type, options = {})
        record(:rename_enum_value, [type, options])
      end

      private

      def invert_create_enum(args)
        [:drop_enum, args]
      end

      def invert_rename_enum_value(args)
        type, args = args
        reversed   = %i[from to].zip(args.values_at(:to, :from))

        [:rename_enum_value, [type, Hash[reversed]]]
      end

      def invert_rename_enum(args)
        [:rename_enum, [args.last[:to], to: args.first]]
      end

      def invert_drop_enum(args)
        raise ActiveRecord::IrreversibleMigration, "drop_enum is only reversible if given a list of values" unless args.length > 1
        [:create_enum, args]
      end

      def invert_add_enum_value(args)
        raise ActiveRecord::IrreversibleMigration, "ENUM values cannot be removed once added. Drop and Replace it instead at your own risk."
      end
    end
  end
end
