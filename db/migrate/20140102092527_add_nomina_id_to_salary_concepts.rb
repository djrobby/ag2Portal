class AddNominaIdToSalaryConcepts < ActiveRecord::Migration
  def change
    add_column :salary_concepts, :nomina_id, :string

    add_index :salary_concepts, :nomina_id
  end
end
