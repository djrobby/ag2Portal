class AddOrganizationToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :organization_id, :integer
  end
end
