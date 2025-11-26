class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.references :league, null: false, foreign_key: true
      t.references :home_team, null: false, foreign_key: { to_table: :teams }
      t.references :away_team, null: false, foreign_key: { to_table: :teams }
      t.integer :round, null: false
      t.string :status, null: false, default: "pending" # pending, lineup_submitted, in_progress, completed
      t.references :winner_team, foreign_key: { to_table: :teams }
      t.integer :home_score, default: 0
      t.integer :away_score, default: 0
      t.datetime :scheduled_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :matches, [:league_id, :round]
    add_index :matches, :status
  end
end
