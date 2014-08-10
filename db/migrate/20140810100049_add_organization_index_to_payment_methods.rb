class AddOrganizationIndexToPaymentMethods < ActiveRecord::Migration
  def change
    add_index :payment_methods, :organization_id    
  end
end
