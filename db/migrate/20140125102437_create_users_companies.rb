class CreateUsersCompanies < ActiveRecord::Migration
  def change
    create_table :users_companies, id: false do |t|
      t.integer :user_id
      t.integer :company_id
    end
    add_index :users_companies, [:user_id, :company_id]
  end
end
