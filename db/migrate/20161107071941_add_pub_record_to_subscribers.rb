class AddPubRecordToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :pub_record, :string

    add_index :subscribers, :pub_record
  end
end
