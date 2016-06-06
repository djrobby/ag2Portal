class CreateWorkOrderTypeAccounts < ActiveRecord::Migration
  def change
    create_table :work_order_type_accounts do |t|
      t.references :work_order_type
      t.references :project
      t.references :charge_account

      t.timestamps
    end
    add_index :work_order_type_accounts, :work_order_type_id
    add_index :work_order_type_accounts, :project_id
    add_index :work_order_type_accounts, :charge_account_id
    add_index :work_order_type_accounts,
              [:work_order_type_id, :project_id, :charge_account_id],
              unique: true, name: 'index_wo_type_accounts_unique'
  end
end
