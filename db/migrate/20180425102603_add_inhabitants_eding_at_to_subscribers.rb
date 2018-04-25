class AddInhabitantsEdingAtToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :inhabitants_ending_at, :date
  end
end
