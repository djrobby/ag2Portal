class AddCreatedByToCalibers < ActiveRecord::Migration
  def change
    add_column :calibers, :created_by, :integer
    add_column :calibers, :updated_by, :integer
  end
end
