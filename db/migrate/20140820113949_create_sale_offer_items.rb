class CreateSaleOfferItems < ActiveRecord::Migration
  def change
    create_table :sale_offer_items do |t|
      t.references :sale_offer
      t.references :product
      t.string :description
      t.decimal :quantity
      t.decimal :price
      t.decimal :discount_pct
      t.decimal :discount
      t.references :tax_type
      t.date :delivery_date
      t.references :project
      t.references :store
      t.references :work_order
      t.references :charge_account

      t.timestamps
    end
    add_index :sale_offer_items, :sale_offer_id
    add_index :sale_offer_items, :product_id
    add_index :sale_offer_items, :tax_type_id
    add_index :sale_offer_items, :project_id
    add_index :sale_offer_items, :store_id
    add_index :sale_offer_items, :work_order_id
    add_index :sale_offer_items, :charge_account_id
    add_index :sale_offer_items, :description
  end
end
