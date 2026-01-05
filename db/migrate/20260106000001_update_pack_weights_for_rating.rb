class UpdatePackWeightsForRating < ActiveRecord::Migration[8.0]
  def change
    remove_columns :packs, :common_weight, :rare_weight, :epic_weight, :legendary_weight
    add_column :packs, :bronze_weight, :integer, default: 50, null: false
    add_column :packs, :silver_weight, :integer, default: 30, null: false
    add_column :packs, :gold_weight, :integer, default: 15, null: false
    add_column :packs, :diamond_weight, :integer, default: 4, null: false
    add_column :packs, :master_weight, :integer, default: 1, null: false
    add_column :packs, :legend_weight, :integer, default: 0, null: false
  end
end
