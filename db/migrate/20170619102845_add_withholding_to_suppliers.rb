class AddWithholdingToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :withholding_rate, :decimal, :precision => 6, :scale => 2, :null => false, :default => 0
  end
end
