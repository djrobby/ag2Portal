class AddCreatedByToOfferRequestSuppliers < ActiveRecord::Migration
  def change
    add_column :offer_request_suppliers, :created_by, :integer
    add_column :offer_request_suppliers, :updated_by, :integer
  end
end
