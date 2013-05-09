class AddCreatedByToCollectiveAgreements < ActiveRecord::Migration
  def change
    add_column :collective_agreements, :created_by, :integer
    add_column :collective_agreements, :updated_by, :integer
  end
end
