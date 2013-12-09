class CreateOfferRequestItems < ActiveRecord::Migration
  def change
    create_table :offer_request_items do |t|
      t.references :offer_request
      t.references :product
      t.string :description
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :tax_type

      t.timestamps
    end
    add_index :offer_request_items, :offer_request_id
    add_index :offer_request_items, :product_id
    add_index :offer_request_items, :tax_type_id
    add_index :offer_request_items, :description
  end
end
