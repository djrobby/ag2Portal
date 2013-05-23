class AddCreatedByToTicketCategory < ActiveRecord::Migration
  def change
    add_column :ticket_categories, :created_by, :integer
    add_column :ticket_categories, :updated_by, :integer
  end
end
