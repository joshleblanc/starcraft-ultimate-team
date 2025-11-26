class AddTeamToUserCards < ActiveRecord::Migration[8.1]
  def change
    add_reference :user_cards, :team, foreign_key: true, null: true
    change_column_null :user_cards, :user_id, true
  end
end
