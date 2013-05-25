class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.references :ticket_category
      t.references :ticket_priority
      t.string :ticket_subject
      t.string :ticket_message
      t.references :ticket_status
      t.references :technician
      t.timestamp :assign_at
      t.timestamp :status_changed_at
      t.string :status_changed_message

      t.timestamps
    end
    add_index :tickets, :ticket_category_id
    add_index :tickets, :ticket_priority_id
    add_index :tickets, :ticket_status_id
    add_index :tickets, :technician_id
    add_index :tickets, :ticket_subject
    add_index :tickets, :created_at
    add_index :tickets, :assign_at
    add_index :tickets, :status_changed_at
  end
end
