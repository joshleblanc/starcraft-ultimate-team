class AddOverallRatingToCards < ActiveRecord::Migration[8.1]
  def change
    add_column :cards, :overall_rating, :integer, null: false, default: 50
    add_index :cards, :overall_rating

    # Backfill existing cards
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE cards 
          SET overall_rating = ROUND((macro + micro + starsense + poise + speed) / 5.0)
        SQL
      end
    end
  end
end
