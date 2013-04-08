class AddAttachmentAvatarToCorpContacts < ActiveRecord::Migration
  def self.up
    change_table :corp_contacts do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :corp_contacts, :avatar
  end
end
