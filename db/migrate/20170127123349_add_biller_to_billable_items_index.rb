class AddBillerToBillableItemsIndex < ActiveRecord::Migration
  def change
    remove_index :billable_items, name: 'index_billable_items_unique'

    add_index :billable_items,
              [:project_id, :billable_concept_id, :biller_id],
              unique: true, name: 'index_billable_items_unique'
  end
end
