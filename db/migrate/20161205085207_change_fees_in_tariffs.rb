class ChangeFeesInTariffs < ActiveRecord::Migration
  def change
    change_column :tariffs, :fixed_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :variable_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :block1_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :block2_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :block3_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :block4_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :block5_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :block6_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :block7_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :tariffs, :block8_fee, :decimal, precision: 12, scale: 6, null: false, default: '0'
  end
end
