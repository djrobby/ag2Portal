class AddMeasuresToBillingFrequencies < ActiveRecord::Migration
  def change
    add_column :billing_frequencies, :fix_measure_id, :integer
    add_column :billing_frequencies, :var_measure_id, :integer

    add_index :billing_frequencies, :fix_measure_id
    add_index :billing_frequencies, :var_measure_id
  end
end
