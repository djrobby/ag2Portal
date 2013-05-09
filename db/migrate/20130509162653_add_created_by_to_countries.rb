class AddCreatedByToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :created_by, :integer
    add_column :countries, :updated_by, :integer
  end
end
