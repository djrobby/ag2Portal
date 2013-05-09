class AddCreatedByToApps < ActiveRecord::Migration
  def change
    add_column :apps, :created_by, :integer
    add_column :apps, :updated_by, :integer
  end
end
