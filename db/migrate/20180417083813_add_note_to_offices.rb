class AddNoteToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :invoice_note, :string
  end
end
