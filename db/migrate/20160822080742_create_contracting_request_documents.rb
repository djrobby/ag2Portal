class CreateContractingRequestDocuments < ActiveRecord::Migration
  def change
    create_table :contracting_request_documents do |t|
      t.references :contracting_request
      t.references :contracting_request_document_type

      t.timestamps
    end
    add_index :contracting_request_documents, :contracting_request_id
    add_index :contracting_request_documents, :contracting_request_document_type_id, name: 'index_contracting_request_document_type'
  end
end
