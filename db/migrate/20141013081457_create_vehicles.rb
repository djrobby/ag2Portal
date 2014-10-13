class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.references :organization
      t.references :company
      t.references :office
      t.references :product
      t.string :name
      t.string :registration
      t.string :brand
      t.string :model
      t.decimal :cost, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :vehicles, :organization_id
    add_index :vehicles, :company_id
    add_index :vehicles, :office_id
    add_index :vehicles, :product_id
    add_index :vehicles, :registration
    add_index :vehicles, [:organization_id, :registration], unique: true, name: 'index_vehicles_on_organization_and_registration'
  end
end
