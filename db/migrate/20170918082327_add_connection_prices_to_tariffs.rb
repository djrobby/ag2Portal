class AddConnectionPricesToTariffs < ActiveRecord::Migration
  def change
    add_column :tariffs, :connection_fee_a, :decimal, precision: 12, scale: 6, null: false, default: 0
    add_column :tariffs, :connection_fee_b, :decimal, precision: 12, scale: 6, null: false, default: 0
  end
end
