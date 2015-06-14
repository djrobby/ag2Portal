class AddAttachmentAttachmentToReceiptNotes < ActiveRecord::Migration
  def self.up
    change_table :receipt_notes do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :receipt_notes, :attachment
  end
end
