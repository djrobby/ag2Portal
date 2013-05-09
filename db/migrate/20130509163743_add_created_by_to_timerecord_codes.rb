class AddCreatedByToTimerecordCodes < ActiveRecord::Migration
  def change
    add_column :timerecord_codes, :created_by, :integer
    add_column :timerecord_codes, :updated_by, :integer
  end
end
