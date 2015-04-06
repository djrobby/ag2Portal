class AddCreatedByToRatios < ActiveRecord::Migration
  def change
    add_column :ratios, :created_by, :integer
    add_column :ratios, :updated_by, :integer
  end
end
