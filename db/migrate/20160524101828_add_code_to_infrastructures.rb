class AddCodeToInfrastructures < ActiveRecord::Migration
  def change
    add_column :infrastructures, :code, :string

    add_index :infrastructures, :code
    add_index :infrastructures, [:organization_id, :code], unique: true, name: 'index_infraestructure_unique'
  end
end
