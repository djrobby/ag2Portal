class ChangeFloorInClients < ActiveRecord::Migration
  def change
    change_column :clients, :floor, :string
  end
end
