class CreateReadingRoutes < ActiveRecord::Migration
  def change
    create_table :reading_routes do |t|
      t.references :project
      t.references :office
      t.string :routing_code
      t.string :name

      t.timestamps
    end
    add_index :reading_routes, :project_id
    add_index :reading_routes, :office_id
    add_index :reading_routes, :routing_code
    add_index :reading_routes, [:office_id, :routing_code], unique: true, name: 'index_reading_routes_unique'
  end
end
