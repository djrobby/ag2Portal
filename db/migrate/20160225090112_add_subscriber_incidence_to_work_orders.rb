class AddSubscriberIncidenceToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :subscriber_id, :integer
    add_column :work_orders, :incidences, :string

    add_index :work_orders, :subscriber_id
  end
end
