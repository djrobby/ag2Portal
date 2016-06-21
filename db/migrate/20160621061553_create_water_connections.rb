class CreateWaterConnections < ActiveRecord::Migration
  def change
    create_table :water_connections do |t|
      t.references :water_connection_type
      t.string :code
      t.string :name
      t.string :gis_id

      t.timestamps
    end
    add_index :water_connections, :water_connection_type_id
  end
end
