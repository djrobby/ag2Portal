class AddIndexNameToWorkers < ActiveRecord::Migration
  def change
    add_index :workers, :first_name
    add_index :workers, :last_name
  end
end
