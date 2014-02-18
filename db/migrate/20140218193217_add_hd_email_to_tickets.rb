class AddHdEmailToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :hd_email, :string
  end
end
