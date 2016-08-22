class AddCreatedByToContractingRequestDocumentTypes < ActiveRecord::Migration
  def change
    add_column :contracting_request_document_types, :created_by, :integer
    add_column :contracting_request_document_types, :updated_by, :integer
  end
end
