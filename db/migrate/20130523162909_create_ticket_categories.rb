class CreateTicketCategories < ActiveRecord::Migration
  def change
    create_table :ticket_categories do |t|
      t.string :name

      t.timestamps
    end
    add_index :ticket_categories, :name
  end
end
