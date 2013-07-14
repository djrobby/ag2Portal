class AddCreatedByToSupplier < ActiveRecord::Migration
  def change
    add_column :suppliers, :created_by, :integer
    add_column :suppliers, :updated_by, :integer
  end
end
