class AddIsContactToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :is_contact, :boolean
  end
end
