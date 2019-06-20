class AddStatusToQuux < ActiveRecord::Migration::Current
  def change
    create_table :quux do |t|
      t.enum :status, as: "status_type"
    end
  end
end
