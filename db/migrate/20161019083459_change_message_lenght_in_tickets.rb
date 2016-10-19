class ChangeMessageLenghtInTickets < ActiveRecord::Migration
  def change
    change_column :tickets, :ticket_message, :string, :limit => 1000
  end
end
