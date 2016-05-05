class AddWorkerToZones < ActiveRecord::Migration
  def change
    add_column :zones, :worker_id, :integer

    add_index :zones, :worker_id
  end
end
