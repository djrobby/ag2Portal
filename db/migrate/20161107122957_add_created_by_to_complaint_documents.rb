class AddCreatedByToComplaintDocuments < ActiveRecord::Migration
  def change
    add_column :complaint_documents, :created_by, :integer
    add_column :complaint_documents, :updated_by, :integer
  end
end
