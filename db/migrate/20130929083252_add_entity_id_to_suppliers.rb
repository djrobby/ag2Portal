class AddEntityIdToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :entity_id, :integer

    add_index :suppliers, :entity_id
  end
end
