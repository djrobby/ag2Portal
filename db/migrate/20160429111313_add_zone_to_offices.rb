class AddZoneToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :zone_id, :integer

    add_index :offices, :zone_id
  end
end
