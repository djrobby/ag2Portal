class CreateSaleOffers < ActiveRecord::Migration
  def change
    create_table :sale_offers do |t|
      t.references :client
      t.references :payment_method
      t.references :sale_offer_status
      t.string :offer_no
      t.date :offer_date
      t.string :remarks
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.references :project
      t.references :store
      t.references :work_order
      t.references :charge_account
      t.references :organization

      t.timestamps
    end
    add_index :sale_offers, :client_id
    add_index :sale_offers, :payment_method_id
    add_index :sale_offers, :sale_offer_status_id
    add_index :sale_offers, :project_id
    add_index :sale_offers, :store_id
    add_index :sale_offers, :work_order_id
    add_index :sale_offers, :charge_account_id
    add_index :sale_offers, :organization_id
    add_index :sale_offers, :offer_no
    add_index :sale_offers, :offer_date
    add_index :sale_offers, [:organization_id, :offer_no], unique: true
  end
end
