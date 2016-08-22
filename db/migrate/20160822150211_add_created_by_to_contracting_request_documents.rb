class AddCreatedByToContractingRequestDocuments < ActiveRecord::Migration
  def change
    add_column :contracting_request_documents, :created_by, :integer
    add_column :contracting_request_documents, :updated_by, :integer
  end
end
