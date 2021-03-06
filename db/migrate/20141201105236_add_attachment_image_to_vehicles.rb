class AddAttachmentImageToVehicles < ActiveRecord::Migration
  def self.up
    change_table :vehicles do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :vehicles, :image
  end
end
