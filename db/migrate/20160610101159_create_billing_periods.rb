class CreateBillingPeriods < ActiveRecord::Migration
  def change
    create_table :billing_periods do |t|
      t.references :project
      t.references :billing_frequency
      t.integer :period
      t.string :description
      t.date :reading_starting_date
      t.date :reading_ending_date
      t.date :prebilling_starting_date
      t.date :prebilling_ending_date
      t.date :billing_starting_date
      t.date :billing_ending_date
      t.date :charging_starting_date
      t.date :charging_ending_date

      t.timestamps
    end
    add_index :billing_periods, :project_id
    add_index :billing_periods, :billing_frequency_id
    add_index :billing_periods, :period
    add_index :billing_periods, [:project_id, :period], unique: true, name: 'index_billing_periods_unique'
  end
end
