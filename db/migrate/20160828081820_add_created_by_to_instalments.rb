class AddCreatedByToInstalments < ActiveRecord::Migration
  def change
    add_column :instalments, :created_by, :integer
    add_column :instalments, :updated_by, :integer
  end
end
