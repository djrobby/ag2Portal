class ChangeSubscriberMeterInWorkOrderTypes < ActiveRecord::Migration
  def change
    change_column :work_order_types, :subscriber_meter, :boolean, :default => false
  end
end
