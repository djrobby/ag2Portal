class AddStartingEndingToSubscriberTariffs < ActiveRecord::Migration
  def change
    add_column :subscriber_tariffs, :starting_at, :date
    add_column :subscriber_tariffs, :ending_at, :date

    add_index :subscriber_tariffs, :starting_at
    add_index :subscriber_tariffs, :ending_at
  end
end
