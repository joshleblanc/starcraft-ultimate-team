class CreateLeagues < ActiveRecord::Migration[8.1]
  def change
    create_table :leagues do |t|
      t.string :name, null: false
      t.string :status, null: false, default: "pending" # pending, active, completed
      t.integer :max_teams, null: false, default: 8
      t.integer :current_round, default: 0
      t.integer :total_rounds, default: 7 # round-robin
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end

    add_index :leagues, :status
  end
end
