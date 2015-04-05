class CreateRatioGroups < ActiveRecord::Migration
  def change
    create_table :ratio_groups do |t|
      t.string :code
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :ratio_groups, :organization_id
    add_index :ratio_groups, :code
    add_index :ratio_groups, [:organization_id, :code], unique: true, name: 'index_ratio_groups_on_organization_and_code'
  end
end
