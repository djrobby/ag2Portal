class CreateComplaintDocumentTypes < ActiveRecord::Migration
  def change
    create_table :complaint_document_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :complaint_document_types, :name
  end
end
