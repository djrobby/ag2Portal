class ChangeFloorInWorkers < ActiveRecord::Migration
  def change
    change_column :workers, :floor, :string
  end
end
