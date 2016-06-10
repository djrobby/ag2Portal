class AddCreatedByToBillingFrequencies < ActiveRecord::Migration
  def change
    add_column :billing_frequencies, :created_by, :integer
    add_column :billing_frequencies, :updated_by, :integer
  end
end
