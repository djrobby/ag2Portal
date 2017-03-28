class AddTotalsToDeliveryNotes < ActiveRecord::Migration
  def self.up
    add_column :delivery_notes, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :delivery_notes, :total_costs, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    DeliveryNote.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:total_costs, p.costs)
    end
  end

  def self.down
    remove_column :delivery_notes, :totals
    remove_column :delivery_notes, :total_costs
  end
end
