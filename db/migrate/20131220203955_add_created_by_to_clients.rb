class AddCreatedByToClients < ActiveRecord::Migration
  def change
    add_column :clients, :created_by, :integer
    add_column :clients, :updated_by, :integer
  end
end
