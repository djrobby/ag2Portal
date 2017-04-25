class CreatePaymentTypes < ActiveRecord::Migration
  def change
    create_table :payment_types do |t|
      t.string :name
      t.references :payment_method
      t.references :organization

      t.timestamps
    end
    add_index :payment_types, :payment_method_id
    add_index :payment_types, :organization_id
  end
end
