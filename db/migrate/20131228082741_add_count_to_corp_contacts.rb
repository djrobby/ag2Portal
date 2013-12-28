class AddCountToCorpContacts < ActiveRecord::Migration
  def change
    add_column :corp_contacts, :worker_count, :integer, :limit => 2
  end
end
