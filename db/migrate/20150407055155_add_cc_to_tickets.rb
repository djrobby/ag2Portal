class AddCcToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :cc_id, :integer
  end
end
