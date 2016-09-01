class AddKmToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :km, :string
    add_column :service_points, :km, :string
  end
end
