class AddStatuses < ActiveRecord::Migration[5.2]
  def up
    create_enum "status_type", "active", "archived"
  end

  def down
    drop_enum :status_type
  end
end
