class AddWorkerTypeToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :worker_type_id, :integer

    add_index :workers, :worker_type_id
  end
end
