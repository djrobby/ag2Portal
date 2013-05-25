class AddAttachmentAttachmentToTickets < ActiveRecord::Migration
  def self.up
    change_table :tickets do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :tickets, :attachment
  end
end
