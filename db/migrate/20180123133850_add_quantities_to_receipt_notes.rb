class AddQuantitiesToReceiptNotes < ActiveRecord::Migration
  def self.up
    add_column :receipt_notes, :quantities, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0
    add_column :receipt_notes, :taxables, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    ReceiptNote.find_each do |p|
      p.update_column(:quantities, p.quantity)
      p.update_column(:taxables, p.taxable)
    end
  end

  def self.down
    remove_column :receipt_notes, :quantities
    remove_column :receipt_notes, :taxables
  end
end
