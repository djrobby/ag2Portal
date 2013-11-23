class CreateOrderStatuses < ActiveRecord::Migration
  def change
    create_table :order_statuses do |t|
      t.string :name
      t.boolean :approval
      t.boolean :notification

      t.timestamps
    end
    add_index :order_statuses, :name
  end
end
