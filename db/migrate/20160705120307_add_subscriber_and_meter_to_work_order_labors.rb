class AddSubscriberAndMeterToWorkOrderLabors < ActiveRecord::Migration
  def change
    add_column :work_order_labors, :subscriber_meter, :boolean
  end
end
