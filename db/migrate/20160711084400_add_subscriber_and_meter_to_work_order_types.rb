class AddSubscriberAndMeterToWorkOrderTypes < ActiveRecord::Migration
  def change
    add_column :work_order_types, :subscriber_meter, :boolean
  end
end
