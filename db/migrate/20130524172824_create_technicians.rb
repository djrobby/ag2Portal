class CreateTechnicians < ActiveRecord::Migration
  def change
    create_table :technicians do |t|
      t.string :name
      t.references :user

      t.timestamps
    end
    add_index :technicians, :name
    add_index :technicians, :user_id
  end
end
