class AddNominaIdToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :nomina_id, :string

    add_index :workers, :nomina_id
  end
end
