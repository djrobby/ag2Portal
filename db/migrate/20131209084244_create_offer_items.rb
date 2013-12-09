class CreateOfferItems < ActiveRecord::Migration
  def change
    create_table :offer_items do |t|
      t.references :offer
      t.references :product
      t.string :code
      t.string :description
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :tax_type
      t.date :delivery_date

      t.timestamps
    end
    add_index :offer_items, :offer_id
    add_index :offer_items, :product_id
    add_index :offer_items, :tax_type_id
    add_index :offer_items, :description
    add_index :offer_items, :code
  end
end
