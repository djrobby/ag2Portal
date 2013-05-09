class AddCreatedByToSharedContactTypes < ActiveRecord::Migration
  def change
    add_column :shared_contact_types, :created_by, :integer
    add_column :shared_contact_types, :updated_by, :integer
  end
end
