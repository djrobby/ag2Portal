class AddCreatedByToFormalities < ActiveRecord::Migration
  def change
    add_column :formalities, :created_by, :integer
    add_column :formalities, :updated_by, :integer
  end
end
