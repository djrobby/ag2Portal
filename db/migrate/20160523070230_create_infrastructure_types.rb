class CreateInfrastructureTypes < ActiveRecord::Migration
  def change
    create_table :infrastructure_types do |t|
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :infrastructure_types, :organization_id
  end
end
