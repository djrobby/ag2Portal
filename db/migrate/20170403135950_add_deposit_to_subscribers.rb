class AddDepositToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :deposit, :decimal, precision: 13, scale: 4, null: false, default: 0
  end
end
