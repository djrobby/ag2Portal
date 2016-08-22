class AddCreatedByToTariffs < ActiveRecord::Migration
  def change
    add_column :tariffs, :created_by, :integer
    add_column :tariffs, :updated_by, :integer
  end
end
