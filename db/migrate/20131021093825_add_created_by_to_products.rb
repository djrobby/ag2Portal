class AddCreatedByToProducts < ActiveRecord::Migration
  def change
    add_column :products, :created_by, :integer
    add_column :products, :updated_by, :integer
  end
end
