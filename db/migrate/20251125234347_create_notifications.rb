class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.string :type, null: false
      t.json :params
      t.datetime :read_at

      t.timestamps
    end
    
    add_index :notifications, :read_at
    add_index :notifications, [:recipient_type, :recipient_id, :read_at], name: "index_notifications_on_recipient_and_read"
  end
end
