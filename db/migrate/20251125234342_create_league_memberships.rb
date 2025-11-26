class CreateLeagueMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :league_memberships do |t|
      t.references :league, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :points, default: 0
      t.integer :match_wins, default: 0
      t.integer :match_losses, default: 0
      t.integer :game_wins, default: 0
      t.integer :game_losses, default: 0

      t.timestamps
    end

    add_index :league_memberships, [:league_id, :points]
    add_index :league_memberships, [:league_id, :team_id], unique: true
  end
end
