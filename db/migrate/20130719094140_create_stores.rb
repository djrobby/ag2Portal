class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.references :company
      t.references :office
      t.string :location

      t.timestamps
    end
    add_index :stores, :company_id
    add_index :stores, :office_id
  end
end
