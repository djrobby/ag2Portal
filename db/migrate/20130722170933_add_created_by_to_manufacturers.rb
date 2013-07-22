class AddCreatedByToManufacturers < ActiveRecord::Migration
  def change
    add_column :manufacturers, :created_by, :string
    add_column :manufacturers, :updated_by, :string
  end
end
