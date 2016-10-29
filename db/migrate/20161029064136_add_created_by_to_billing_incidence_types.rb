class AddCreatedByToBillingIncidenceTypes < ActiveRecord::Migration
  def change
    add_column :billing_incidence_types, :created_by, :integer
    add_column :billing_incidence_types, :updated_by, :integer
  end
end
