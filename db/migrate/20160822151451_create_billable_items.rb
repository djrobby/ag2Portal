class CreateBillableItems < ActiveRecord::Migration
  def change
    create_table :billable_items do |t|
      t.references :project
      t.references :billable_concept
      t.references :biller
      t.references :regulation

      t.timestamps
    end
    add_index :billable_items, :project_id
    add_index :billable_items, :billable_concept_id
    add_index :billable_items, :biller_id
    add_index :billable_items, :regulation_id
    add_index :billable_items,
              [:project_id, :billable_concept_id],
              unique: true, name: 'index_billable_items_unique'
  end
end
