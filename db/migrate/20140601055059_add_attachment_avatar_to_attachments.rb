class AddAttachmentAvatarToAttachments < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :attachments, :avatar
  end
end
