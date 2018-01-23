class AddQuantitiesToDeliveryNotes < ActiveRecord::Migration
  def self.up
    add_column :delivery_notes, :quantities, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    DeliveryNote.find_each do |p|
      p.update_column(:quantities, p.quantity)
    end
  end

  def self.down
    remove_column :delivery_notes, :quantities
  end
end
