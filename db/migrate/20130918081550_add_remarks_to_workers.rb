class AddRemarksToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :remarks, :string
  end
end
