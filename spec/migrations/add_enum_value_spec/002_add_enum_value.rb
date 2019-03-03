class AddEnumValue < ActiveRecord::Migration::Current
  disable_ddl_transaction!

  def change
    add_enum_value "another_test_type", "baz", after: "bar"
  end
end
