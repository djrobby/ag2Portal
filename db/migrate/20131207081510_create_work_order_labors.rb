class CreateWorkOrderLabors < ActiveRecord::Migration
  def change
    create_table :work_order_labors do |t|
      t.string :name

      t.timestamps
    end
  end
end
