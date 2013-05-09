class AddCreatedByToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :created_by, :integer
    add_column :offices, :updated_by, :integer
  end
end
