class AddCreatedByToContractingRequestTypes < ActiveRecord::Migration
  def change
    add_column :contracting_request_types, :created_by, :integer
    add_column :contracting_request_types, :updated_by, :integer
  end
end
