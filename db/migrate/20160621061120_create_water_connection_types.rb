class CreateWaterConnectionTypes < ActiveRecord::Migration
  def change
    create_table :water_connection_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
