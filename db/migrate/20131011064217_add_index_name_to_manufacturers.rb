class AddIndexNameToManufacturers < ActiveRecord::Migration
  def change
    add_index :manufacturers, :name
  end
end
