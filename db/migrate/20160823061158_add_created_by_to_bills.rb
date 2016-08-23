class AddCreatedByToBills < ActiveRecord::Migration
  def change
    add_column :bills, :created_by, :integer
    add_column :bills, :updated_by, :integer
  end
end
