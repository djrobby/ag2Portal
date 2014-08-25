class CreateChargeGroups < ActiveRecord::Migration
  def change
    create_table :charge_groups do |t|
      t.string :group_code
      t.string :name
      t.integer :flow, :limit => 2
      t.string :ledger_account
      t.references :organization

      t.timestamps
    end
    add_index :charge_groups, :organization_id
    add_index :charge_groups, :group_code
    add_index :charge_groups, :name
    add_index :charge_groups, :ledger_account
    add_index :charge_groups, :flow
    add_index :charge_groups, [:organization_id, :group_code], unique: true, name: 'index_charge_groups_on_organization_and_code'
  end
end
