class AddWorkerToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :worker_id, :integer

    add_index :areas, :worker_id
  end
end
