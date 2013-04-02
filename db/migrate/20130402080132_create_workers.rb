class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :first_name
      t.string :last_name
      t.string :worker_code
      t.string :fiscal_id
      t.references :user
      t.references :company
      t.references :office
      t.date :starting_at
      t.date :ending_at
      t.references :street_type
      t.string :street_name
      t.string :street_number
      t.string :building
      t.integer :floor
      t.string :floor_office
      t.references :zipcode
      t.references :town
      t.references :province
      t.string :phone
      t.string :cellular
      t.string :email

      t.timestamps
    end
    add_index :workers, :worker_code
    add_index :workers, :fiscal_id
    add_index :workers, :user_id
    add_index :workers, :company_id
    add_index :workers, :office_id
    add_index :workers, :street_type_id
    add_index :workers, :zipcode_id
    add_index :workers, :town_id
    add_index :workers, :province_id
  end
end
