class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.references :match, null: false, foreign_key: true
      t.integer :game_number, null: false # 1-5 for best of 5
      t.references :home_player, null: false, foreign_key: { to_table: :user_cards }
      t.references :away_player, null: false, foreign_key: { to_table: :user_cards }
      t.string :status, null: false, default: "pending" # pending, in_progress, completed
      t.references :winner_player, foreign_key: { to_table: :user_cards }
      t.references :winner_team, foreign_key: { to_table: :teams }
      
      # Game phase results: 'home', 'away', 'even'
      t.string :early_game_result
      t.string :mid_game_result
      t.string :late_game_result
      t.string :deciding_phase # which phase decided the game
      
      # Detailed simulation data (JSON)
      t.json :simulation_log

      t.timestamps
    end

    add_index :games, [:match_id, :game_number], unique: true
  end
end
