class AddCreatedByToSupplierContact < ActiveRecord::Migration
  def change
    add_column :supplier_contacts, :created_by, :string
    add_column :supplier_contacts, :updated_by, :string
  end
end
