class CreateSupplierContacts < ActiveRecord::Migration
  def change
    create_table :supplier_contacts do |t|
      t.references :supplier
      t.string :first_name
      t.string :last_name
      t.string :fiscal_id
      t.string :position
      t.string :department
      t.string :phone
      t.string :extension
      t.string :cellular
      t.string :email
      t.string :remarks

      t.timestamps
    end
    add_index :supplier_contacts, :supplier_id
    add_index :supplier_contacts, :first_name
    add_index :supplier_contacts, :last_name
    add_index :supplier_contacts, :fiscal_id
    add_index :supplier_contacts, :email
    add_index :supplier_contacts, :phone
    add_index :supplier_contacts, :cellular
  end
end
