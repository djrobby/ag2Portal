class AddCreatedByToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :created_by, :string
    add_column :entities, :updated_by, :string
  end
end
