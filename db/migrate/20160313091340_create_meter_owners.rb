class CreateMeterOwners < ActiveRecord::Migration
  def change
    create_table :meter_owners do |t|
      t.string :name

      t.timestamps
    end
    add_index :meter_owners, :name
  end
end
