class AddRoleToClients < ActiveRecord::Migration
  def change
    add_column :clients, :role_id, :integer, default: 0
  end
end
