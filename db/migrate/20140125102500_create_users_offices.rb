class CreateUsersOffices < ActiveRecord::Migration
  def change
    create_table :users_offices, id: false do |t|
      t.integer :user_id
      t.integer :office_id
    end
    add_index :users_offices, [:user_id, :office_id]
  end
end
