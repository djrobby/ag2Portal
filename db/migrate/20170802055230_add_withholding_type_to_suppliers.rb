class AddWithholdingTypeToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :withholding_type_id, :integer
    add_index :suppliers, :withholding_type_id
  end
end
