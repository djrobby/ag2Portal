class AddCreatedByToComplaintDocumentTypes < ActiveRecord::Migration
  def change
    add_column :complaint_document_types, :created_by, :integer
    add_column :complaint_document_types, :updated_by, :integer
  end
end
