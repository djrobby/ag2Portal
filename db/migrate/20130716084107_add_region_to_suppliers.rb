class AddRegionToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :region_id, :integer
    add_column :suppliers, :country_id, :integer

    add_index :suppliers, :region_id
    add_index :suppliers, :country_id
  end
end
