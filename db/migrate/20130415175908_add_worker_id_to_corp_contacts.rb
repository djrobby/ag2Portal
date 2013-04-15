class AddWorkerIdToCorpContacts < ActiveRecord::Migration
  def change
    add_column :corp_contacts, :worker_id, :integer

    add_index :corp_contacts, :worker_id
  end
end
