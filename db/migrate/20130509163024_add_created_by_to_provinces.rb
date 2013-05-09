class AddCreatedByToProvinces < ActiveRecord::Migration
  def change
    add_column :provinces, :created_by, :integer
    add_column :provinces, :updated_by, :integer
  end
end
