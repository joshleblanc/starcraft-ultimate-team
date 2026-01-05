class CreateExchangeRedemptions < ActiveRecord::Migration[8.0]
  def change
    create_table :exchange_redemptions do |t|
      t.references :set_exchange, null: false, foreign_key: true
      t.references :exchange_slot, null: false, foreign_key: true
      t.references :user_card, null: false, foreign_key: true
      t.references :output_user_card, null: false, foreign_key: { to_table: :user_cards }
      t.timestamps
    end

  end
end
