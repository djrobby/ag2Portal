class AddOrganizationToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :organization_id, :integer
  end
end
