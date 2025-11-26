class AddCpuToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :is_cpu, :boolean, null: false, default: false
    change_column_null :teams, :user_id, true
  end
end
