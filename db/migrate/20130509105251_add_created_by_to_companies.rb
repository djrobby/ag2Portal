class AddCreatedByToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :created_by, :integer
    add_column :companies, :updated_by, :integer
  end
end
