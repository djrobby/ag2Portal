class AddUseToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :use_id, :integer

    add_index :subscribers, :use_id
  end
end
