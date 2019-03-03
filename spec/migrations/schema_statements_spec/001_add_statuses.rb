class AddStatuses < ActiveRecord::Migration::Current
  def up
    create_enum "status_type", %w[active archived]
  end

  def down
    drop_enum :status_type
  end
end
