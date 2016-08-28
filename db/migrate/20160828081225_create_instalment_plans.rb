class CreateInstalmentPlans < ActiveRecord::Migration
  def change
    create_table :instalment_plans do |t|
      t.string :instalment_no
      t.date :instalment_date
      t.references :payment_method
      t.references :client
      t.references :subscriber
      t.decimal :surcharge_pct, :precision => 6, :scale => 2, :null => false, :default => '0'

      t.timestamps
    end
    add_index :instalment_plans, :payment_method_id
    add_index :instalment_plans, :client_id
    add_index :instalment_plans, :subscriber_id
    add_index :instalment_plans, :instalment_no
    add_index :instalment_plans, :instalment_date
  end
end
