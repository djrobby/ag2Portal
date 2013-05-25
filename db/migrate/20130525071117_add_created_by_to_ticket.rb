class AddCreatedByToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :created_by, :integer
    add_column :tickets, :updated_by, :integer
  end
end
