class CreateComplaintDocuments < ActiveRecord::Migration
  def change
    create_table :complaint_documents do |t|
      t.references :complaint
      t.references :complaint_document_type
      t.integer :flow, limit: 1, null: false, default: '1'

      t.timestamps
    end
    add_index :complaint_documents, :complaint_id
    add_index :complaint_documents, :complaint_document_type_id
    add_index :complaint_documents, :flow
  end
end
