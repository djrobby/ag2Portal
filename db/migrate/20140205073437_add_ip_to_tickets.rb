class AddIpToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :source_ip, :string
  end
end
