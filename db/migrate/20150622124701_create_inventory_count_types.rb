class CreateInventoryCountTypes < ActiveRecord::Migration
  def change
    create_table :inventory_count_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
