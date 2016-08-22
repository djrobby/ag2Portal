class CreateBillableConcepts < ActiveRecord::Migration
  def change
    create_table :billable_concepts do |t|
      t.string :code
      t.string :name
      t.string :billable_document

      t.timestamps
    end
    add_index :billable_concepts, :code
  end
end
