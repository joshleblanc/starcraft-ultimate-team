class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :rating, default: 1000 # ELO-style rating

      t.timestamps
    end

    add_index :teams, :rating
  end
end
