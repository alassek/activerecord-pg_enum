# ActiveRecord::PGEnum [![Build Status](https://travis-ci.com/alassek/activerecord-pg_enum.svg?branch=master)](https://travis-ci.com/alassek/activerecord-pg_enum)

The `enum` feature in Rails has bad developer ergonomics. It uses integer types at the DB layer, which means trying to understand SQL output is a pain.

Using the easy form of the helper syntax is a minor footgun:

```ruby
enum status: %w[new active archived]
```

It's not obvious that the above code is order-dependent, but if you decide to add a new enum anywhere but the end, you're in trouble.

If you choose the use `varchar` fields instead, now you have to write annoying check constraints and lose the efficient storage.

```ruby
enum status: { new: "new", active: "active", archived: "archived" }
```

Nobody has time to write that nonsense.

## Enumerated Types: The Best of Both Worlds

Did you know you can define your own types in PostgreSQL? You can, and this type system also supports enumeration.

```SQL
CREATE TYPE status_type AS ENUM ('new', 'active', 'archived');
```

Not only does this give you full type safety at the DB layer, the implementation is highly efficient. An enum value only takes up [four bytes](https://www.postgresql.org/docs/11/datatype-enum.html).

The best part is that PostgreSQL supports inserting new values at any point of the list without having to migrate your data.

```SQL
ALTER TYPE status_type ADD VALUE 'pending' BEFORE 'active';
```

## schema.rb Support

The principle motivation of this gem is to seamlessly integrate PG enums into your `schema.rb` file. This means you can use them in your database columns without switching to `structure.sql`.

```ruby
ActiveRecord::Schema.define(version: 2019_06_19_214914) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_enum "status_type", %w[new pending active archived]
  
  create_table "orders", id: :serial, force: :cascade do |t|
    t.enum "status", as: "status_type", default: "new"
  end

end
```

## Version support

Every version of Rails with an `enum` macro is supported. This means 4.1 through master. Yes, this was annoying and difficult.

The monkeypatches in this library are extremely narrow and contained; the dirty hacks I had to do to make 4.1 work, for instance, have no impact on 6.0.

Monkeypatching Rails internals is **scary**. So this library has a comprehensive test suite that runs against every known minor version.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-pg_enum'
```

And then execute:

    $ bundle

## Usage

### Migrations

Defining a new ENUM

```ruby
class AddContactMethodType < ActiveRecord::Migration[5.2]
  def up
    create_enum "contact_method_type", %w[Email Phone]
  end

  def down
    drop_enum "contact_method_type"
  end
end
```

Adding a value to an existing ENUM

```ruby
class AddSMSToContactMethodType < ActiveRecord::Migration[5.2]
  def up
    add_enum_value "contact_method_type", "SMS", before: "Phone"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```

Adding an enum column to a table

```ruby
class AddStatusToOrder < ActiveRecord::Migration[5.2]
  def change
    change_table :orders do |t|
      t.enum :status, as: "status_type", default: "new"
    end
  end
end
```

Renaming an enum type

```ruby
class RenameStatusType < ActiveRecord::Migration[6.0]
  def change
    rename_enum "status_type", to: "order_status_type"
  end
end
```

```SQL
ALTER TYPE status_type RENAME TO order_status_type;
```

**PostgreSQL 10+ required**:

Changing an enum label

```ruby
class ChangeStatusHoldLabel < ActiveRecord::Migration[6.0]
  def change
    rename_enum_value "status_type", from: "on hold", to: "OnHold"
  end
end
```

```SQL
ALTER TYPE status_type RENAME VALUE 'on hold' TO 'OnHold';
```

### Module Builder

```ruby
class ContactInfo < ActiveRecord::Base
  include PGEnum(contact_method: %w[Email SMS Phone])
end
```

The generated module calls the official `enum` method converting array syntax into strings. The above example is equivalent to:

```ruby
class ContactInfo < ActiveRecord::Base
  enum contact_method: { Email: "Email", SMS: "SMS", Phone: "Phone" }
end
```

Additionally, `enum` options are fully supported, for example
```ruby
class User < ActiveRecord::Base
  include PGEnum(status: %w[active inactive deleted], _prefix: 'user', _suffix: true)
end
```

is equivalent to
```ruby
class User < ActiveRecord::Base
  enum status: { active: 'active', inactive: 'inactive', deleted: 'deleted' }, _prefix: 'user', _suffix: true
end
```

There's no technical reason why you couldn't detect enum columns at startup time and automatically do this wireup, but I feel that the benefit of self-documenting outweighs the convenience.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `appraisal rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Test a specific version with `appraisal 6.0 rake spec`. This is usually necessary because different versions have different Ruby version support.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alassek/activerecord-pg_enum.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
