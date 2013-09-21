class AddCreatedByToEntityTypes < ActiveRecord::Migration
  def change
    add_column :entity_types, :created_by, :string
    add_column :entity_types, :updated_by, :string
  end
end
