class AddCreatedByToZipcodes < ActiveRecord::Migration
  def change
    add_column :zipcodes, :created_by, :integer
    add_column :zipcodes, :updated_by, :integer
  end
end
