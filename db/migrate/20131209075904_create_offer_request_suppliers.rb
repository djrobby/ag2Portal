class CreateOfferRequestSuppliers < ActiveRecord::Migration
  def change
    create_table :offer_request_suppliers do |t|
      t.references :offer_request
      t.references :supplier

      t.timestamps
    end
    add_index :offer_request_suppliers, :offer_request_id
    add_index :offer_request_suppliers, :supplier_id
  end
end
