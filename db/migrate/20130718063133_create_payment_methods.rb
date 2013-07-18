class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.string :description
      t.integer :expiration_days, :null => false, :default => '0'
      t.decimal :default_interest, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :payment_methods, :description
  end
end
