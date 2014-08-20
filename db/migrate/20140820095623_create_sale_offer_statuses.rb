class CreateSaleOfferStatuses < ActiveRecord::Migration
  def change
    create_table :sale_offer_statuses do |t|
      t.string :name
      t.boolean :approval
      t.boolean :notification

      t.timestamps
    end
    add_index :sale_offer_statuses, :name
  end
end
