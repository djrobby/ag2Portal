class AddCreatedByToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :created_by, :integer
    add_column :subscribers, :updated_by, :integer
  end
end
