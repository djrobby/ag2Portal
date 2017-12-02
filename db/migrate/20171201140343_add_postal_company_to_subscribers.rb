class AddPostalCompanyToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :postal_company, :string
  end
end
