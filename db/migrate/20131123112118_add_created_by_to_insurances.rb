class AddCreatedByToInsurances < ActiveRecord::Migration
  def change
    add_column :insurances, :created_by, :integer
    add_column :insurances, :updated_by, :integer
  end
end
