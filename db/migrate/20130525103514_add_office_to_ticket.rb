class AddOfficeToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :office_id, :integer

    add_index :tickets, :office_id
    add_index :tickets, :created_by
  end
end
