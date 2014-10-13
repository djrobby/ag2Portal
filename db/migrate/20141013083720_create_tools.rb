class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.references :organization
      t.references :company
      t.references :office
      t.references :product
      t.string :name
      t.string :serial_no
      t.string :brand
      t.string :model
      t.decimal :cost, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :tools, :organization_id
    add_index :tools, :company_id
    add_index :tools, :office_id
    add_index :tools, :product_id
    add_index :tools, :serial_no
    add_index :tools, [:organization_id, :serial_no], unique: true, name: 'index_tools_on_organization_and_serial'
  end
end
