class CreateStoreOffices < ActiveRecord::Migration
  def change
    create_table :store_offices do |t|
      t.references :store
      t.references :office

      t.timestamps
    end
    add_index :store_offices, :store_id
    add_index :store_offices, :office_id
  end
end
