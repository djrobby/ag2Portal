class ChangeTypeInCashMovementTypes < ActiveRecord::Migration
  def change
    remove_index :cash_movement_types, :type_id
    change_column :cash_movement_types, :type_id, :integer, :limit => 2, null: false, default: 1
    add_index :cash_movement_types, :type_id
  end
end
