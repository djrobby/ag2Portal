class CreateBillingFrequencies < ActiveRecord::Migration
  def change
    create_table :billing_frequencies do |t|
      t.string :name
      t.integer :months, :limit => 2, :null => false, :default => '0'
      t.integer :days, :limit => 2, :null => false, :default => '0'

      t.timestamps
    end
  end
end
