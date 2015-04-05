class CreateRatios < ActiveRecord::Migration
  def change
    create_table :ratios do |t|
      t.string :code
      t.string :name
      t.references :organization
      t.references :ratio_group
      t.string :formula

      t.timestamps
    end
    add_index :ratios, :organization_id
    add_index :ratios, :ratio_group_id
    add_index :ratios, :code
    add_index :ratios, [:organization_id, :ratio_group_id, :code], unique: true, name: 'index_ratios_on_organization_group_code'
  end
end
