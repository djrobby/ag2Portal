class ChangeActiveInSubscribers < ActiveRecord::Migration
  def change
    change_column :subscribers, :active, :boolean, null: false, default: true
  end
end
