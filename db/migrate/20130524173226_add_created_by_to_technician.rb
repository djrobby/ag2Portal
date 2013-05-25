class AddCreatedByToTechnician < ActiveRecord::Migration
  def change
    add_column :technicians, :created_by, :integer
    add_column :technicians, :updated_by, :integer
  end
end
