class AddPercentageFixedFeeToTariffs < ActiveRecord::Migration
  def change
    add_column :tariffs, :percentage_fixed_fee, :decimal, precision: 6, scale: 2, null: false, default: 0
  end
end
