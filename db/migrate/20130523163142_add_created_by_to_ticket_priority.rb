class AddCreatedByToTicketPriority < ActiveRecord::Migration
  def change
    add_column :ticket_priorities, :created_by, :integer
    add_column :ticket_priorities, :updated_by, :integer
  end
end
