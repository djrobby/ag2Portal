class AddCreatedByToCashMovements < ActiveRecord::Migration
  def change
    add_column :cash_movements, :created_by, :integer
    add_column :cash_movements, :updated_by, :integer
  end
end
