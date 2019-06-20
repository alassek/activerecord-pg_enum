# ActiveRecord::PGEnum [![Build Status](https://travis-ci.com/getflywheel/activerecord-pg_enum.svg?branch=master)](https://travis-ci.com/getflywheel/activerecord-pg_enum)

This gem is a small monkeypatch to ActiveRecord so that your `schema.rb` file can support PostgreSQL's native enumerated types.

This will allow you to use enum columns in your database without replacing `schema.rb` with `structure.sql`.

## Version support

I intend to support every version of Rails that supports `enum`, which was introduced in 4.1.

Currently Rails 5.0 through 6.0 are supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-pg_enum'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-pg_enum

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
      t.enum :status, as: "status_type"
    end
  end
end
```

### Module Builder

```ruby
class ContactInfo < ActiveRecord::Base
  include ActiveRecord::PGEnum(contact_method: %w[Email SMS Phone])
end
```

The generated module calls the official `enum` method converting array syntax into strings. The above example is equivalent to:

```ruby
class ContactInfo < ActiveRecord::Base
  enum contact_method: { Email: "Email", SMS: "SMS", Phone: "Phone" }
end
```

There's no technical reason why you couldn't detect enum columns at startup time and automatically do this wireup, but I feel that the benefit of self-documenting outweighs the convenience.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/getflywheel/activerecord-pg_enum.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
