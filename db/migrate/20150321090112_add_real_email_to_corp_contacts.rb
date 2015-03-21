class AddRealEmailToCorpContacts < ActiveRecord::Migration
  def change
    add_column :corp_contacts, :real_email, :boolean, :default => true
  end
end
