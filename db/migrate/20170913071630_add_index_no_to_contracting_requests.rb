class AddIndexNoToContractingRequests < ActiveRecord::Migration
  def change
    add_index :contracting_requests, :request_no
  end
end
