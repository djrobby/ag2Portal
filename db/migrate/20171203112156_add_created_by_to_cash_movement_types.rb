class AddCreatedByToCashMovementTypes < ActiveRecord::Migration
  def change
    add_column :cash_movement_types, :created_by, :integer
    add_column :cash_movement_types, :updated_by, :integer
  end
end
