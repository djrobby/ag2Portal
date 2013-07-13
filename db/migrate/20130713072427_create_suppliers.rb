class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :supplier_code
      t.string :fiscal_id

      t.timestamps
    end
    add_index :suppliers, :name
    add_index :suppliers, :supplier_code
    add_index :suppliers, :fiscal_id
  end
end
