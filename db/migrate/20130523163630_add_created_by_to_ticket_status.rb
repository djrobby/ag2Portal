class AddCreatedByToTicketStatus < ActiveRecord::Migration
  def change
    add_column :ticket_statuses, :created_by, :integer
    add_column :ticket_statuses, :updated_by, :integer
  end
end
