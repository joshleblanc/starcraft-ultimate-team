class CreateExchangeSlotsAndQualifications < ActiveRecord::Migration[8.0]
  def change
    create_table :exchange_slots do |t|
      t.references :set_exchange, null: false, foreign_key: true
      t.integer :position, null: false
      t.timestamps
    end

    create_table :exchange_qualifications do |t|
      t.references :exchange_slot, null: false, foreign_key: true
      t.string :qualification_type, null: false
      t.integer :card_set_id
      t.integer :card_id
      t.integer :min_rating
      t.integer :max_rating
      t.timestamps
    end

    add_index :exchange_slots, [ :set_exchange_id, :position ], unique: true
    add_index :exchange_qualifications, :qualification_type
  end
end
