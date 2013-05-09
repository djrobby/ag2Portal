class AddCreatedByToTimerecordTypes < ActiveRecord::Migration
  def change
    add_column :timerecord_types, :created_by, :integer
    add_column :timerecord_types, :updated_by, :integer
  end
end
