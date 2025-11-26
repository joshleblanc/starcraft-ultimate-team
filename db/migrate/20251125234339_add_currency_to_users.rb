class AddCurrencyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :credits, :integer, null: false, default: 1000
    add_column :users, :username, :string
    add_index :users, :username, unique: true
  end
end
