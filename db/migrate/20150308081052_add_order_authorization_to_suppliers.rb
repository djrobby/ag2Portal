class AddOrderAuthorizationToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :order_authorization, :boolean
  end
end
