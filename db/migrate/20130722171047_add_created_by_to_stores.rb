class AddCreatedByToStores < ActiveRecord::Migration
  def change
    add_column :stores, :created_by, :string
    add_column :stores, :updated_by, :string
  end
end
