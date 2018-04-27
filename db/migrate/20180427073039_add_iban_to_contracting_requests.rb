class AddIbanToContractingRequests < ActiveRecord::Migration
  def change
    add_column :contracting_requests, :iban, :string
    add_index :contracting_requests, :iban
  end
end
