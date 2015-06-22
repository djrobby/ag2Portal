class CreateInventoryCounts < ActiveRecord::Migration
  def change
    create_table :inventory_counts do |t|
      t.string :count_no
      t.date :count_date
      t.references :inventory_count_type
      t.references :store
      t.references :product_family
      t.references :organization
      t.string :remarks

      t.timestamps
    end
    add_index :inventory_counts, :inventory_count_type_id
    add_index :inventory_counts, :store_id
    add_index :inventory_counts, :product_family_id
    add_index :inventory_counts, :organization_id
    add_index :inventory_counts, :count_no
    add_index :inventory_counts, :count_date
    add_index :inventory_counts, [:organization_id, :count_no], unique: true
  end
end
