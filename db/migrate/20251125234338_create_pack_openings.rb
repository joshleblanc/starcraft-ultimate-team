class CreatePackOpenings < ActiveRecord::Migration[8.1]
  def change
    create_table :pack_openings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pack, null: false, foreign_key: true
      t.datetime :opened_at, null: false
      
      t.timestamps
    end

    add_index :pack_openings, [:user_id, :opened_at]
  end
end
