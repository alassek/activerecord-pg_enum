class AddEnumValue < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_enum_value "another_test_type", "baz", after: "bar"
  end
end
