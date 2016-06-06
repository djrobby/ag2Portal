class AddCreatedByToWorkOrderTypeAccounts < ActiveRecord::Migration
  def change
    add_column :work_order_type_accounts, :created_by, :integer
    add_column :work_order_type_accounts, :updated_by, :integer
  end
end
