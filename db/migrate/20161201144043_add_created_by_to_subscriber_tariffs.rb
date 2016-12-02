class AddCreatedByToSubscriberTariffs < ActiveRecord::Migration
  def change
    add_column :subscriber_tariffs, :created_by, :integer
    add_column :subscriber_tariffs, :updated_by, :integer
  end
end
