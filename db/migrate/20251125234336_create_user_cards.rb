class CreateUserCards < ActiveRecord::Migration[8.1]
  def change
    create_table :user_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true
      t.boolean :is_starter, default: false
      t.integer :position # position in lineup (1-5 for starters)
      
      t.timestamps
    end

    add_index :user_cards, [:user_id, :is_starter]
  end
end
