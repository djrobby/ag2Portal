class CreateInventoryTransfers < ActiveRecord::Migration
  def change
    create_table :inventory_transfers do |t|
      t.string :transfer_no
      t.date :transfer_date
      t.references :organization
      t.references :company
      t.references :outbound_store
      t.references :inbound_store
      t.references :approver
      t.timestamp :approval_date

      t.timestamps
    end
    add_index :inventory_transfers, :organization_id
    add_index :inventory_transfers, :company_id
    add_index :inventory_transfers, :outbound_store_id
    add_index :inventory_transfers, :inbound_store_id
    add_index :inventory_transfers, :approver_id
    add_index :inventory_transfers, :transfer_no
    add_index :inventory_transfers, :transfer_date
    add_index :inventory_transfers, [:organization_id, :transfer_no], unique: true
  end
end
