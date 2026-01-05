class RemoveRarityFromCards < ActiveRecord::Migration[8.0]
  def change
    remove_column :cards, :rarity, :string, null: false, default: "common"
  end
end
