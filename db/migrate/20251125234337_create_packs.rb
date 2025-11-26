class CreatePacks < ActiveRecord::Migration[8.1]
  def change
    create_table :packs do |t|
      t.string :name, null: false
      t.string :pack_type, null: false, default: "standard" # standard, premium, legendary
      t.integer :card_count, null: false, default: 5
      t.integer :cost, null: false, default: 100 # in-game currency
      t.text :description
      
      # Probability weights for rarities
      t.integer :common_weight, default: 70
      t.integer :rare_weight, default: 20
      t.integer :epic_weight, default: 8
      t.integer :legendary_weight, default: 2
      
      t.timestamps
    end
  end
end
