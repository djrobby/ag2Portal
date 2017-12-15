class AddCreatedByToBillingIncidences < ActiveRecord::Migration
  def change
    add_column :billing_incidences, :created_by, :integer
    add_column :billing_incidences, :updated_by, :integer
  end
end
