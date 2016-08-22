class AddCreatedByToContractingRequestStatuses < ActiveRecord::Migration
  def change
    add_column :contracting_request_statuses, :created_by, :integer
    add_column :contracting_request_statuses, :updated_by, :integer
  end
end
