class CreateCashMovements < ActiveRecord::Migration
  def change
    create_table :cash_movements do |t|
      t.references :cash_movement_type
      t.references :payment_method
      t.date :movement_date
      t.decimal :amount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :organization
      t.references :company
      t.references :office
      t.references :project
      t.references :charge_account

      t.timestamps
    end
    add_index :cash_movements, :cash_movement_type_id
    add_index :cash_movements, :payment_method_id
    add_index :cash_movements, :movement_date
    add_index :cash_movements, :organization_id
    add_index :cash_movements, :company_id
    add_index :cash_movements, :office_id
    add_index :cash_movements, :project_id
    add_index :cash_movements, :charge_account_id
  end
end
