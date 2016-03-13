class CreateMeterTypes < ActiveRecord::Migration
  def change
    create_table :meter_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :meter_types, :name
  end
end
