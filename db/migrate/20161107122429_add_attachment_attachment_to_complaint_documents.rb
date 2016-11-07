class AddAttachmentAttachmentToComplaintDocuments < ActiveRecord::Migration
  def self.up
    change_table :complaint_documents do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :complaint_documents, :attachment
  end
end
