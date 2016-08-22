class CreateTariffs < ActiveRecord::Migration
  def change
    create_table :tariffs do |t|
      t.references :tariff_scheme
      t.references :billable_item
      t.references :tariff_type
      t.references :caliber
      t.references :billing_frequency
      t.decimal :fixed_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :variable_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :percentage_fee, precision: 6, scale: 2, null: false, default: 0
      t.string :percentage_applicable_formula
      t.integer :block1_limit
      t.integer :block2_limit
      t.integer :block3_limit
      t.integer :block4_limit
      t.integer :block5_limit
      t.integer :block6_limit
      t.integer :block7_limit
      t.integer :block8_limit
      t.decimal :block1_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :block2_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :block3_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :block4_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :block5_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :block6_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :block7_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :block8_fee, precision: 10, scale: 4, null: false, default: 0
      t.decimal :discount_pct_f, precision: 6, scale: 2, null: false, default: 0
      t.decimal :discount_pct_v, precision: 6, scale: 2, null: false, default: 0
      t.decimal :discount_pct_p, precision: 6, scale: 2, null: false, default: 0
      t.decimal :discount_pct_b, precision: 6, scale: 2, null: false, default: 0
      t.references :tax_type_f
      t.references :tax_type_v
      t.references :tax_type_p
      t.references :tax_type_b

      t.timestamps
    end
    add_index :tariffs, [:tariff_scheme_id, :billable_item_id, :tariff_type_id ,:caliber_id, :billing_frequency_id], :unique => true, :name => 'index_tariffs_unique'
    add_index :tariffs, :tariff_scheme_id
    add_index :tariffs, :billable_item_id
    add_index :tariffs, :tariff_type_id
    add_index :tariffs, :caliber_id
    add_index :tariffs, :billing_frequency_id
    add_index :tariffs, :tax_type_f_id
    add_index :tariffs, :tax_type_v_id
    add_index :tariffs, :tax_type_p_id
    add_index :tariffs, :tax_type_b_id
  end
end
