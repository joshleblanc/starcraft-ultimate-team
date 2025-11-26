class CreateLineups < ActiveRecord::Migration[8.1]
  def change
    create_table :lineups do |t|
      t.references :match, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.boolean :submitted, default: false

      t.timestamps
    end

    add_index :lineups, [:match_id, :team_id], unique: true
  end
end
