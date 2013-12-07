class CreateWorkOrderStatuses < ActiveRecord::Migration
  def change
    create_table :work_order_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
