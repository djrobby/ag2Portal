class ChangeFloorInSubscribers < ActiveRecord::Migration
  def change
    change_column :subscribers, :floor, :string
  end
end
