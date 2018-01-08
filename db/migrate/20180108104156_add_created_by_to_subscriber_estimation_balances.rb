class AddCreatedByToSubscriberEstimationBalances < ActiveRecord::Migration
  def change
    add_column :subscriber_estimation_balances, :created_by, :integer
    add_column :subscriber_estimation_balances, :updated_by, :integer
  end
end
