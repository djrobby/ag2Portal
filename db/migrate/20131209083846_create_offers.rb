class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.references :offer_request
      t.references :supplier
      t.references :payment_method
      t.string :offer_no
      t.date :offer_date
      t.string :remarks

      t.timestamps
    end
    add_index :offers, :offer_request_id
    add_index :offers, :supplier_id
    add_index :offers, :payment_method_id
    add_index :offers, :offer_no
    add_index :offers, :offer_date
  end
end
