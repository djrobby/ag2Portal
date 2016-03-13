class AddCreatedByToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :created_by, :integer
    add_column :meters, :updated_by, :integer
  end
end
