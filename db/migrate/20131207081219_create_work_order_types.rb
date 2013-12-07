class CreateWorkOrderTypes < ActiveRecord::Migration
  def change
    create_table :work_order_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
