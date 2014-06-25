class AddCreatedByToSubguides < ActiveRecord::Migration
  def change
    add_column :subguides, :created_by, :integer
    add_column :subguides, :updated_by, :integer
  end
end
