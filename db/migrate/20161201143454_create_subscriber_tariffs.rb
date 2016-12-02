class CreateSubscriberTariffs < ActiveRecord::Migration
  def change
    create_table :subscriber_tariffs do |t|
      t.references :subscriber
      t.references :tariff

      t.timestamps
    end
    add_index :subscriber_tariffs, :subscriber_id
    add_index :subscriber_tariffs, :tariff_id
  end
end
