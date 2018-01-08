class CreateSubscriberEstimationBalances < ActiveRecord::Migration
  def change
    create_table :subscriber_estimation_balances do |t|
      t.references :subscriber
      t.integer :estimation_balance, :null => false, :default => 0
      t.timestamp :estimation_init_at
      t.timestamp :estimation_reset_at

      t.timestamps
    end
    add_index :subscriber_estimation_balances, :subscriber_id
  end
end
