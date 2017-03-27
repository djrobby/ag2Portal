class AddTotalsToReceiptNotes < ActiveRecord::Migration
  def self.up
    add_column :receipt_notes, :totals, :decimal, :precision => 13, :scale => 4, :null => false, :default => 0

    ReceiptNote.find_each do |p|
      p.update_column(:totals, p.total)
    end
  end

  def self.down
    remove_column :receipt_notes, :totals
  end
end
