class CreateWorkerSalaryItems < ActiveRecord::Migration
  def change
    create_table :worker_salary_items do |t|
      t.references :worker_salary
      t.references :salary_concept
      t.decimal :amount, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :worker_salary_items, :worker_salary_id
    add_index :worker_salary_items, :salary_concept_id
  end
end
