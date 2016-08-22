class CreateContractingRequestDocumentTypes < ActiveRecord::Migration
  def change
    create_table :contracting_request_document_types do |t|
      t.string :name
      t.boolean :required

      t.timestamps
    end
  end
end
