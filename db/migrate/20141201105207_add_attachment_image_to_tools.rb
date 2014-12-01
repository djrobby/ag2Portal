class AddAttachmentImageToTools < ActiveRecord::Migration
  def self.up
    change_table :tools do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :tools, :image
  end
end
