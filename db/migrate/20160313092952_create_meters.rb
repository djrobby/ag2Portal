class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|
      t.string :meter_code
      t.references :meter_model
      t.references :caliber
      t.references :meter_owner
      t.date :manufacturing_date
      t.integer :manufacturing_year
      t.date :expiry_date
      t.date :purchase_date
      t.date :first_installation_date
      t.date :last_withdrawal_date
      t.references :organization

      t.timestamps
    end
    add_index :meters, :meter_model_id
    add_index :meters, :caliber_id
    add_index :meters, :meter_owner_id
    add_index :meters, :organization_id
    add_index :meters, :manufacturing_year
  end
end
