class AddRealEmailToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :real_email, :boolean, :default => true
  end
end
