class CreateSetExchanges < ActiveRecord::Migration[8.0]
  def change
    create_table :set_exchanges do |t|
      t.references :card_set, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :output_min_rating, null: false
      t.integer :output_max_rating, null: false
      t.integer :output_count, default: 1, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    add_index :set_exchanges, [ :card_set_id, :active ]
  end
end
