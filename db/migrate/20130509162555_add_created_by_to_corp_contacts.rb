class AddCreatedByToCorpContacts < ActiveRecord::Migration
  def change
    add_column :corp_contacts, :created_by, :integer
    add_column :corp_contacts, :updated_by, :integer
  end
end
