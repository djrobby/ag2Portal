class ChangeCodeIndexInBillableConcepts < ActiveRecord::Migration
  def change
    remove_index :billable_concepts, :code
    add_index :billable_concepts, :code, unique: true
  end
end
