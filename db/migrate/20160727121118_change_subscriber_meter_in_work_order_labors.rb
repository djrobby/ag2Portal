class ChangeSubscriberMeterInWorkOrderLabors < ActiveRecord::Migration
  def change
    change_column :work_order_labors, :subscriber_meter, :boolean, :default => false
  end
end
