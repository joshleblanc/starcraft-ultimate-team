class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.string :name, null: false
      t.string :race, null: false # Terran, Zerg, Protoss
      t.string :rarity, null: false, default: "common" # common, rare, epic, legendary
      t.string :player_role, default: "player" # player, coach
      
      # Core stats (1-100 scale)
      t.integer :macro, null: false, default: 50
      t.integer :micro, null: false, default: 50
      t.integer :starsense, null: false, default: 50 # game sense, decision making
      t.integer :poise, null: false, default: 50 # composure under pressure
      t.integer :speed, null: false, default: 50 # APM, reaction time
      
      # Game phase modifiers (percentage bonus, -20 to +20)
      t.integer :early_game, null: false, default: 0
      t.integer :mid_game, null: false, default: 0
      t.integer :late_game, null: false, default: 0
      
      # Card image/art reference
      t.string :image_url
      
      t.timestamps
    end

    add_index :cards, :rarity
    add_index :cards, :race
  end
end
