class CreateUsersOrganizations < ActiveRecord::Migration
  def change
    create_table :users_organizations, id: false do |t|
      t.integer :user_id
      t.integer :organization_id
    end
    add_index :users_organizations, [:user_id, :organization_id]
  end
end
