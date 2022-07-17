# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 1) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # These are custom enum types that must be created before they can be used in the schema definition
  create_enum "foo_type", ['bar', 'baz', 'fizz buzz']

  create_table "test_table", id: :serial, force: :cascade do |t|
    if Gem.loaded_specs['activerecord'].version < Gem::Version.new('7.0')
      t.enum "foo", as: "foo_type", null: false
    else
      t.enum "foo", enum_type: "foo_type", null: false
    end
  end

end
