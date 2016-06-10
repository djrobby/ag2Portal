class AddCreatedByToBillingPeriods < ActiveRecord::Migration
  def change
    add_column :billing_periods, :created_by, :integer
    add_column :billing_periods, :updated_by, :integer
  end
end
