class AddCreatedByToContractingRequests < ActiveRecord::Migration
  def change
    add_column :contracting_requests, :created_by, :integer
    add_column :contracting_requests, :updated_by, :integer
  end
end
