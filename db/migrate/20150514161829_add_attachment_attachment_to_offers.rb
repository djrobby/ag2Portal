class AddAttachmentAttachmentToOffers < ActiveRecord::Migration
  def self.up
    change_table :offers do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :offers, :attachment
  end
end
