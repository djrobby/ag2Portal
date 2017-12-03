class CreateCashMovementTypes < ActiveRecord::Migration
  def change
    create_table :cash_movement_types do |t|
      t.string :code, :limit => 3, :null => false
      t.string :name
      t.string :type_id, :limit => 1, :null => false
      t.references :organization

      t.timestamps
    end
    add_index :cash_movement_types, :code
    add_index :cash_movement_types, :type_id
    add_index :cash_movement_types, :organization_id
    add_index :cash_movement_types,
              [:organization_id, :type_id, :code],
              unique: true, name: 'index_cash_movement_types_unique'
  end
end
