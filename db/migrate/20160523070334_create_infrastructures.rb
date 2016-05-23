class CreateInfrastructures < ActiveRecord::Migration
  def change
    create_table :infrastructures do |t|
      t.string :name
      t.references :infrastructure_type
      t.references :organization
      t.references :company
      t.references :office

      t.timestamps
    end
    add_index :infrastructures, :infrastructure_type_id
    add_index :infrastructures, :organization_id
    add_index :infrastructures, :company_id
    add_index :infrastructures, :office_id
  end
end
