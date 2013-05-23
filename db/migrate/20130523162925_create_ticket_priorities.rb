class CreateTicketPriorities < ActiveRecord::Migration
  def change
    create_table :ticket_priorities do |t|
      t.string :name

      t.timestamps
    end
    add_index :ticket_priorities, :name
  end
end
