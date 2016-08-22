class AddAttachmentAttachmentToContractingRequestDocuments < ActiveRecord::Migration
  def self.up
    change_table :contracting_request_documents do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :contracting_request_documents, :attachment
  end
end
