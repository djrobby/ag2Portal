class AddCreatedByToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :created_by, :integer
    add_column :workers, :updated_by, :integer
  end
end
