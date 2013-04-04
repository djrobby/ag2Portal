class AddAttachmentAvatarToWorkers < ActiveRecord::Migration
  def self.up
    change_table :workers do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :workers, :avatar
  end
end
