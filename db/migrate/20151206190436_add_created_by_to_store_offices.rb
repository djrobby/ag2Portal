class AddCreatedByToStoreOffices < ActiveRecord::Migration
  def change
    add_column :store_offices, :created_by, :integer
    add_column :store_offices, :updated_by, :integer
  end
end
