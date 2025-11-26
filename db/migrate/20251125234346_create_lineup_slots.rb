class CreateLineupSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :lineup_slots do |t|
      t.references :lineup, null: false, foreign_key: true
      t.references :user_card, null: false, foreign_key: true
      t.integer :position, null: false # 1-5, order matters for matchups

      t.timestamps
    end

    add_index :lineup_slots, [:lineup_id, :position], unique: true
    add_index :lineup_slots, [:lineup_id, :user_card_id], unique: true
  end
end
