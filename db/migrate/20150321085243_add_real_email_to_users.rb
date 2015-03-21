class AddRealEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :real_email, :boolean, :default => true
  end
end
