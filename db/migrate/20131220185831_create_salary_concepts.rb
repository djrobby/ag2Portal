class CreateSalaryConcepts < ActiveRecord::Migration
  def change
    create_table :salary_concepts do |t|
      t.string :name

      t.timestamps
    end
    add_index :salary_concepts, :name
  end
end
