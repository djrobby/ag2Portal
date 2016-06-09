class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.references :client
      t.references :office
      t.references :center
      t.string :subscriber_code
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :fiscal_id
      t.date :starting_at
      t.date :ending_at
      t.references :street_directory

      t.timestamps
    end
    add_index :subscribers, :client_id
    add_index :subscribers, :office_id
    add_index :subscribers, :center_id
    add_index :subscribers, :subscriber_code
    add_index :subscribers, :first_name
    add_index :subscribers, :last_name
    add_index :subscribers, :company
    add_index :subscribers, :fiscal_id
    add_index :subscribers, :street_directory_id
    add_index :subscribers, [:office_id, :subscriber_code], unique: true, name: 'index_subscribers_unique'
  end
end
