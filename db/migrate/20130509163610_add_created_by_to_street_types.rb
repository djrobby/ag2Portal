class AddCreatedByToStreetTypes < ActiveRecord::Migration
  def change
    add_column :street_types, :created_by, :integer
    add_column :street_types, :updated_by, :integer
  end
end
