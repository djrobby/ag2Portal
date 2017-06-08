class AddCreatedByToInventoryTransfers < ActiveRecord::Migration
  def change
    add_column :inventory_transfers, :created_by, :integer
    add_column :inventory_transfers, :updated_by, :integer
  end
end
