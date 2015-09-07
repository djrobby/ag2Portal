class AddCreatedByToBankAccountClasses < ActiveRecord::Migration
  def change
    add_column :bank_account_classes, :created_by, :integer
    add_column :bank_account_classes, :updated_by, :integer
  end
end
